import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../../domain/services/bookmarks_sync_controller.dart';
import '../local/bookmark_entity.dart';
import '../local/bookmarks_local_data_source.dart';

/// Offline-first: reads always serve from the local ObjectBox store, writes
/// commit locally first (and mark sync state), then kick a fire-and-forget
/// sync. The UI gets immediate confirmation regardless of network state.
@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  BookmarksRepositoryImpl(this._local, this._sync, this._uuid);

  final BookmarksLocalDataSource _local;
  final BookmarksSyncController _sync;
  final Uuid _uuid;

  @override
  Future<Result<List<Bookmark>>> list() async {
    final rows = await _local.listVisible();
    // Trigger a refresh in the background; reads return immediately.
    unawaited(_sync.sync());
    return Ok(rows.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Bookmark>> get(String id) async {
    final row = await _local.getByUuid(id);
    if (row == null || row.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    return Ok(row.toDomain());
  }

  @override
  Future<Result<Bookmark>> create(BookmarkInput input) async {
    final validation = _validate(input);
    if (validation != null) return Err(validation);
    final normalized = _normalize(input);
    final now = DateTime.now().toUtc();
    final entity = BookmarkEntity(
      uuid: _uuid.v4(),
      title: normalized.title,
      url: normalized.url,
      description: normalized.description,
      tags: List.of(normalized.tags),
      imageUrls: List.of(normalized.imageUrls),
      videoUrl: normalized.videoUrl,
      createdAt: now,
      updatedAt: now,
      syncStateCode: SyncState.pendingCreate.code,
    );
    await _local.putNew(entity);
    unawaited(_sync.sync());
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Bookmark>> update(String id, BookmarkInput input) async {
    final validation = _validate(input);
    if (validation != null) return Err(validation);
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    final normalized = _normalize(input);
    existing.applyInput(normalized, now: DateTime.now().toUtc());
    // pendingCreate stays pendingCreate (still need the initial POST);
    // synced flips to pendingUpdate.
    if (existing.syncState == SyncState.synced) {
      existing.syncState = SyncState.pendingUpdate;
    }
    await _local.put(existing);
    unawaited(_sync.sync());
    return Ok(existing.toDomain());
  }

  @override
  Future<Result<void>> delete(String id) async {
    final existing = await _local.getByUuid(id);
    if (existing == null || existing.syncState == SyncState.pendingDelete) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    // A pendingCreate that's never been synced can be dropped outright —
    // the server has never seen it, so there's nothing to tell it.
    if (existing.syncState == SyncState.pendingCreate) {
      await _local.hardDelete(existing.id);
      return const Ok(null);
    }
    existing.syncState = SyncState.pendingDelete;
    existing.updatedAt = DateTime.now().toUtc();
    await _local.put(existing);
    unawaited(_sync.sync());
    return const Ok(null);
  }

  Failure? _validate(BookmarkInput input) {
    if (input.title.trim().isEmpty) {
      return const ValidationFailure('Title is required.');
    }
    if (input.url.trim().isEmpty) {
      return const ValidationFailure('URL is required.');
    }
    return null;
  }

  /// Trim + dedupe tags so storage matches what the server would compute.
  BookmarkInput _normalize(BookmarkInput input) {
    final seen = <String>{};
    final tags = <String>[];
    for (final raw in input.tags) {
      final t = raw.trim();
      if (t.isEmpty || !seen.add(t)) continue;
      tags.add(t);
    }
    return BookmarkInput(
      title: input.title.trim(),
      url: input.url.trim(),
      description: input.description.trim(),
      tags: tags,
      imageUrls: List.of(input.imageUrls),
      videoUrl: input.videoUrl,
    );
  }
}
