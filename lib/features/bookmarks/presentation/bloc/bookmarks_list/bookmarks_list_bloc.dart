import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/future_extensions.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/services/bookmarks_sync_controller.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/list_bookmarks.dart';
import 'bookmarks_list_state.dart';

part 'bookmarks_list_event.dart';

@injectable
class BookmarksListBloc extends Bloc<BookmarksListEvent, BookmarksListState> {
  BookmarksListBloc(this._list, this._delete, this._sync, this._analytics)
    : super(const BookmarksListState()) {
    on<BookmarksListLoadRequested>(
      _onLoadRequested,
      transformer: sequential(),
    );
    on<BookmarksListQueryChanged>(
      _onQueryChanged,
      transformer: sequential(),
    );
    on<BookmarksListDeleteRequested>(
      _onDeleteRequested,
      transformer: sequential(),
    );
    on<BookmarksListSyncRetried>(_onSyncRetried, transformer: sequential());
    on<_BookmarksSyncStatusChanged>(
      _onSyncStatusChanged,
      transformer: sequential(),
    );
    on<_BookmarksReloadSilentlyRequested>(
      _onReloadSilentlyRequested,
      transformer: sequential(),
    );
    // Reload local data after every sync cycle so server-side changes
    // appear without the user pulling-to-refresh.
    _syncSub = _sync.statusStream.listen((status) {
      if (isClosed) return;
      add(_BookmarksSyncStatusChanged(status));
    });
  }

  final ListBookmarks _list;
  final DeleteBookmark _delete;
  final BookmarksSyncController _sync;
  final AnalyticsService _analytics;
  late final StreamSubscription<BookmarksSyncStatus> _syncSub;
  BookmarksSyncStatus _lastSyncStatus = BookmarksSyncStatus.idle;

  Future<void> _onLoadRequested(
    BookmarksListLoadRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    try {
      await _loadAndEmit(emit);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _loadAndEmit(Emitter<BookmarksListState> emit) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final items):
        emit(state.copyWith(isLoading: false, items: items));
      case Err(:final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _onSyncStatusChanged(
    _BookmarksSyncStatusChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    final status = event.status;
    emit(state.copyWith(syncStatus: status));
    // syncing → idle transition: pull fresh local view (sync may have
    // applied server-side updates or deletes).
    if (_lastSyncStatus == BookmarksSyncStatus.syncing &&
        status != BookmarksSyncStatus.syncing) {
      add(const _BookmarksReloadSilentlyRequested());
    }
    _lastSyncStatus = status;
  }

  Future<void> _onReloadSilentlyRequested(
    _BookmarksReloadSilentlyRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    final result = await _list();
    if (result case Ok(value: final items)) {
      emit(state.copyWith(items: items));
    }
  }

  Future<void> _onSyncRetried(
    BookmarksListSyncRetried event,
    Emitter<BookmarksListState> emit,
  ) async {
    try {
      _analytics.trackBookmarkSyncRetried().uw();
      await _sync.sync();
    } catch (_) {
      rethrow;
    }
  }

  void _onQueryChanged(
    BookmarksListQueryChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    if (event.query == state.query) {
      return;
    }
    final next = state.copyWith(query: event.query);
    emit(next);
    final normalized = event.query.trim();
    if (normalized.isEmpty) {
      return;
    }
    _analytics
        .trackBookmarkSearch(
          queryLength: normalized.length,
          resultCount: next.visibleItems.length,
        )
        .uw();
  }

  Future<void> _onDeleteRequested(
    BookmarksListDeleteRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    final id = event.id;
    final previous = state.items;
    try {
      emit(
        state.copyWith(
          items: previous.where((b) => b.id != id).toList(growable: false),
        ),
      );
      final result = await _delete(id);
      switch (result) {
        case Ok<void>():
          _analytics
              .trackBookmarkDeleted(
                bookmarkId: id,
                source: AnalyticsSources.list,
              )
              .uw();
        case Err(:final failure):
          _analytics
              .trackBookmarkDeleteFailed(
                bookmarkId: id,
                source: AnalyticsSources.list,
                errorType: failure.runtimeType.toString(),
              )
              .uw();
          emit(state.copyWith(items: previous));
          await _loadAndEmit(emit);
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _syncSub.cancel();
    return super.close();
  }
}
