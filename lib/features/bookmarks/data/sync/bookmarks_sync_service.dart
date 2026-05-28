import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/services/bookmarks_sync_controller.dart';
import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmark_entity.dart';
import '../local/bookmarks_local_data_source.dart';
import '../models/bookmark_request.dart';

/// Reconciles the local ObjectBox store with the remote API.
///
/// Triggers:
/// - [sync] is called explicitly on app start (post-auth) and after every
///   local mutation.
/// - Connectivity transitions from offline → online (via connectivity_plus).
///
/// Strategy:
/// 1. **Push**: drain every row in [SyncState.pendingCreate/pendingUpdate/
///    pendingDelete] to the server, marking each `synced` on success. A
///    failure leaves the row in its pending state so the next trigger retries.
/// 2. **Pull**: GET the full server list and reconcile by uuid:
///    - Server-only → insert locally as `synced`.
///    - Both sides → last-write-wins by `updated_at` (server vs local).
///    - Local-only synced row not in server payload → server deleted it
///      elsewhere; remove locally.
///    - Local-only pendingCreate not in server payload → keep, push next time.
///
/// Concurrent calls collapse into one in-flight sync (single-flight). The
/// service is intentionally not a stream-of-bookmarks; the repository keeps
/// owning reads.
@LazySingleton(as: BookmarksSyncController)
class BookmarksSyncService implements BookmarksSyncController {
  BookmarksSyncService(this._local, this._remote, this._connectivity);

  final BookmarksLocalDataSource _local;
  final BookmarksRemoteDataSource _remote;
  final Connectivity _connectivity;

  final _status = StreamController<BookmarksSyncStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Future<void>? _inflight;
  bool _wasOnline = true;

  /// UI subscribes to drive the AppBar indicator. The latest value is also
  /// available via [statusNow].
  @override
  Stream<BookmarksSyncStatus> get statusStream => _status.stream;
  @override
  BookmarksSyncStatus statusNow = BookmarksSyncStatus.idle;

  /// Begin reacting to connectivity changes and run an initial sync. Idempotent.
  @override
  Future<void> start() async {
    if (_connectivitySub != null) return;
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivity,
    );
    final initial = await _connectivity.checkConnectivity();
    _wasOnline = _hasNetwork(initial);
    unawaited(sync());
  }

  /// Stop listening and reset state. Called on sign-out.
  @override
  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  void _onConnectivity(List<ConnectivityResult> result) {
    final online = _hasNetwork(result);
    if (online && !_wasOnline) {
      unawaited(sync());
    }
    _wasOnline = online;
  }

  bool _hasNetwork(List<ConnectivityResult> result) =>
      result.any((r) => r != ConnectivityResult.none);

  /// Public trigger. Concurrent callers share the in-flight future.
  @override
  Future<void> sync() {
    return _inflight ??= _run()..whenComplete(() => _inflight = null);
  }

  Future<void> _run() async {
    _emit(BookmarksSyncStatus.syncing);
    try {
      await _push();
      await _pull();
      _emit(BookmarksSyncStatus.idle);
    } on DioException {
      // Network/auth error — leave pending rows untouched so the next trigger
      // retries. Don't propagate; sync is fire-and-forget from callers.
      _emit(BookmarksSyncStatus.error);
    } on Object catch (_) {
      _emit(BookmarksSyncStatus.error);
    }
  }

  void _emit(BookmarksSyncStatus s) {
    statusNow = s;
    _status.add(s);
  }

  Future<void> _push() async {
    final pending = await _local.listPending();
    for (final row in pending) {
      switch (row.syncState) {
        case SyncState.pendingCreate:
          final dto = await _remote.create(
            BookmarkRequest(
              id: row.uuid,
              title: row.title,
              url: row.url,
              description: row.description,
              tags: row.tags,
              imageUrls: row.imageUrls,
              videoUrl: row.videoUrl,
            ),
          );
          row
            ..syncState = SyncState.synced
            ..serverUpdatedAt = dto.updatedAt
            ..imageUrls = List.of(dto.imageUrls)
            ..videoUrl = dto.videoUrl;
          await _local.put(row);
        case SyncState.pendingUpdate:
          final dto = await _remote.update(
            row.uuid,
            BookmarkRequest(
              title: row.title,
              url: row.url,
              description: row.description,
              tags: row.tags,
              imageUrls: row.imageUrls,
              videoUrl: row.videoUrl,
            ),
          );
          row
            ..syncState = SyncState.synced
            ..serverUpdatedAt = dto.updatedAt
            ..imageUrls = List.of(dto.imageUrls)
            ..videoUrl = dto.videoUrl;
          await _local.put(row);
        case SyncState.pendingDelete:
          try {
            await _remote.delete(row.uuid);
          } on DioException catch (e) {
            // 404 is fine — server already lost it. Anything else, rethrow
            // so the outer catch leaves the row pending for next sync.
            if (e.response?.statusCode != 404) rethrow;
          }
          await _local.hardDelete(row.id);
        case SyncState.synced:
          break;
      }
    }
  }

  Future<void> _pull() async {
    final serverList = await _remote.list();
    final serverByUuid = {for (final dto in serverList) dto.id: dto};
    final localByUuid = <String, BookmarkEntity>{
      for (final row in await _local.listAll()) row.uuid: row,
    };

    // Inserts and updates from the server payload.
    for (final dto in serverList) {
      final local = localByUuid[dto.id];
      if (local == null) {
        await _local.put(
          BookmarkEntity(
            uuid: dto.id,
            title: dto.title,
            url: dto.url,
            description: dto.description,
            tags: List.of(dto.tags),
            imageUrls: List.of(dto.imageUrls),
            videoUrl: dto.videoUrl,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            serverUpdatedAt: dto.updatedAt,
            syncStateCode: SyncState.synced.code,
          ),
        );
        continue;
      }
      // Don't clobber rows the user has touched since the last sync.
      if (local.syncState.isPending) continue;
      // Server has a strictly newer version → take it.
      if (dto.updatedAt.isAfter(local.updatedAt)) {
        local
          ..title = dto.title
          ..url = dto.url
          ..description = dto.description
          ..tags = List.of(dto.tags)
          ..imageUrls = List.of(dto.imageUrls)
          ..videoUrl = dto.videoUrl
          ..updatedAt = dto.updatedAt
          ..serverUpdatedAt = dto.updatedAt;
        await _local.put(local);
      }
    }

    // Server-side deletes: any local `synced` row missing from the payload
    // was deleted on another device.
    for (final local in localByUuid.values) {
      if (local.syncState != SyncState.synced) continue;
      if (serverByUuid.containsKey(local.uuid)) continue;
      await _local.hardDelete(local.id);
    }
  }
}
