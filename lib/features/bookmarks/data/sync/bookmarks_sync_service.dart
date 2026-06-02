import 'dart:async';

import 'package:architecture/architecture.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:network/network.dart';

import '../../domain/services/bookmarks_sync_controller.dart';
import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmarks_local_data_source.dart';
import 'bookmarks_pull_reconciler.dart';
import 'bookmarks_push_queue.dart';

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
  BookmarksSyncService(
    BookmarksLocalDataSource local,
    BookmarksRemoteDataSource remote,
    this._connectivity,
  ) : _pushQueue = BookmarksPushQueue(local, remote),
      _pullReconciler = BookmarksPullReconciler(local, remote);

  final Connectivity _connectivity;
  final BookmarksPushQueue _pushQueue;
  final BookmarksPullReconciler _pullReconciler;

  final _status = StreamController<BookmarksSyncStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Future<void>? _inflight;
  bool _wasOnline = true;
  BookmarksSyncStatus _statusNow = BookmarksSyncStatus.idle;

  /// UI subscribes to drive the AppBar indicator. The latest value is also
  /// available via [statusNow].
  @override
  Stream<BookmarksSyncStatus> get statusStream => _status.stream;
  @override
  BookmarksSyncStatus get statusNow => _statusNow;

  /// Begin reacting to connectivity changes and run an initial sync. Idempotent.
  @override
  Future<void> start() async {
    if (_connectivitySub != null) return;
    _connectivitySub = _connectivity.onConnectivityChanged.listen(
      _onConnectivity,
    );
    final initial = await _connectivity.checkConnectivity();
    _wasOnline = _hasNetwork(initial);
    sync().uw();
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
      sync().uw();
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
      final pushHadFailures = await _pushQueue.push();
      await _pullReconciler.pull();
      // A failed row keeps its pending state and is retried next trigger; we
      // still surface `error` so the UI reflects that the sync was incomplete.
      _emit(
        pushHadFailures ? BookmarksSyncStatus.error : BookmarksSyncStatus.idle,
      );
    } on DioException {
      // Network/auth error — leave pending rows untouched so the next trigger
      // retries. Don't propagate; sync is fire-and-forget from callers.
      _emit(BookmarksSyncStatus.error);
    } on Object catch (_) {
      _emit(BookmarksSyncStatus.error);
    }
  }

  void _emit(BookmarksSyncStatus s) {
    _statusNow = s;
    _status.add(s);
  }
}
