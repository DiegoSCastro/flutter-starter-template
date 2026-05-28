import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/utils/result.dart';
import '../../../domain/services/bookmarks_sync_controller.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/list_bookmarks.dart';
import 'bookmarks_list_state.dart';

@lazySingleton
class BookmarksListCubit extends Cubit<BookmarksListState> {
  BookmarksListCubit(this._list, this._delete, this._sync)
    : super(const BookmarksListState()) {
    // Reload local data after every sync cycle so server-side changes
    // appear without the user pulling-to-refresh.
    _syncSub = _sync.statusStream.listen(_onSyncStatus);
  }

  final ListBookmarks _list;
  final DeleteBookmark _delete;
  final BookmarksSyncController _sync;
  late final StreamSubscription<BookmarksSyncStatus> _syncSub;
  BookmarksSyncStatus _lastSyncStatus = BookmarksSyncStatus.idle;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final items):
        emit(state.copyWith(isLoading: false, items: items));
      case Err(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _onSyncStatus(BookmarksSyncStatus status) {
    emit(state.copyWith(syncStatus: status));
    // syncing → idle transition: pull fresh local view (sync may have
    // applied server-side updates or deletes).
    if (_lastSyncStatus == BookmarksSyncStatus.syncing &&
        status != BookmarksSyncStatus.syncing) {
      unawaited(_reloadSilently());
    }
    _lastSyncStatus = status;
  }

  Future<void> _reloadSilently() async {
    final result = await _list();
    if (result case Ok(value: final items)) {
      emit(state.copyWith(items: items));
    }
  }

  Future<void> retrySync() => _sync.sync();

  /// Updates the search query. Filtering is derived in the state itself
  /// ([BookmarksListState.visibleItems]), so this is a single setState.
  void setQuery(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
  }

  /// Optimistically removes the row, then issues the delete (which marks
  /// tombstone locally + queues the server call).
  Future<void> delete(String id) async {
    final previous = state.items;
    emit(
      state.copyWith(
        items: previous.where((b) => b.id != id).toList(growable: false),
      ),
    );
    final result = await _delete(id);
    if (result is Err) {
      emit(state.copyWith(items: previous));
      await load();
    }
  }

  @override
  Future<void> close() {
    _syncSub.cancel();
    return super.close();
  }
}
