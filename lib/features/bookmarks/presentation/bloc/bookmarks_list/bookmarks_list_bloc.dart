import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/bloc/event_completion.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/services/bookmarks_sync_controller.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/list_bookmarks.dart';
import 'bookmarks_list_state.dart';

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

  Future<void> load() {
    final completer = Completer<void>();
    add(BookmarksListLoadRequested(completer: completer));
    return completer.future;
  }

  Future<void> retrySync() {
    final completer = Completer<void>();
    add(BookmarksListSyncRetried(completer: completer));
    return completer.future;
  }

  /// Updates the search query. Filtering is derived in the state itself
  /// ([BookmarksListState.visibleItems]), so this is a single state update.
  Future<void> setQuery(String query) {
    if (query == state.query) return Future<void>.value();
    final completer = Completer<void>();
    add(BookmarksListQueryChanged(query, completer: completer));
    return completer.future;
  }

  /// Optimistically removes the row, then issues the delete (which marks
  /// tombstone locally + queues the server call).
  Future<void> delete(String id) {
    final completer = Completer<void>();
    add(BookmarksListDeleteRequested(id, completer: completer));
    return completer.future;
  }

  Future<void> _onLoadRequested(
    BookmarksListLoadRequested event,
    Emitter<BookmarksListState> emit,
  ) async {
    try {
      await _loadAndEmit(emit);
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
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
      unawaited(_analytics.trackBookmarkSyncRetried());
      await _sync.sync();
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  void _onQueryChanged(
    BookmarksListQueryChanged event,
    Emitter<BookmarksListState> emit,
  ) {
    if (event.query == state.query) {
      event.completer.completeVoidIfPending();
      return;
    }
    final next = state.copyWith(query: event.query);
    emit(next);
    final normalized = event.query.trim();
    if (normalized.isEmpty) {
      event.completer.completeVoidIfPending();
      return;
    }
    unawaited(
      _analytics.trackBookmarkSearch(
        queryLength: normalized.length,
        resultCount: next.visibleItems.length,
      ),
    );
    event.completer.completeVoidIfPending();
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
          unawaited(
            _analytics.trackBookmarkDeleted(
              bookmarkId: id,
              source: AnalyticsSources.list,
            ),
          );
        case Err(:final failure):
          unawaited(
            _analytics.trackBookmarkDeleteFailed(
              bookmarkId: id,
              source: AnalyticsSources.list,
              errorType: failure.runtimeType.toString(),
            ),
          );
          emit(state.copyWith(items: previous));
          await _loadAndEmit(emit);
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> close() {
    _syncSub.cancel();
    return super.close();
  }
}

sealed class BookmarksListEvent {
  const BookmarksListEvent();
}

final class BookmarksListLoadRequested extends BookmarksListEvent {
  const BookmarksListLoadRequested({this.completer});

  final Completer<void>? completer;
}

final class BookmarksListQueryChanged extends BookmarksListEvent {
  const BookmarksListQueryChanged(this.query, {this.completer});

  final String query;
  final Completer<void>? completer;
}

final class BookmarksListDeleteRequested extends BookmarksListEvent {
  const BookmarksListDeleteRequested(this.id, {this.completer});

  final String id;
  final Completer<void>? completer;
}

final class BookmarksListSyncRetried extends BookmarksListEvent {
  const BookmarksListSyncRetried({this.completer});

  final Completer<void>? completer;
}

final class _BookmarksSyncStatusChanged extends BookmarksListEvent {
  const _BookmarksSyncStatusChanged(this.status);

  final BookmarksSyncStatus status;
}

final class _BookmarksReloadSilentlyRequested extends BookmarksListEvent {
  const _BookmarksReloadSilentlyRequested();
}
