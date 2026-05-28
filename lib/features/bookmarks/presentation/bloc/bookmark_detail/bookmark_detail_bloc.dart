import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/bloc/event_completion.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import 'bookmark_detail_state.dart';

@injectable
class BookmarkDetailBloc
    extends Bloc<BookmarkDetailEvent, BookmarkDetailState> {
  BookmarkDetailBloc(this._get, this._delete, this._analytics)
    : super(const BookmarkDetailState.loading()) {
    on<BookmarkDetailLoadRequested>(
      _onLoadRequested,
      transformer: sequential(),
    );
    on<BookmarkDetailDeleteRequested>(
      _onDeleteRequested,
      transformer: sequential(),
    );
  }

  final GetBookmark _get;
  final DeleteBookmark _delete;
  final AnalyticsService _analytics;

  Future<void> load(String id) {
    final completer = Completer<void>();
    add(BookmarkDetailLoadRequested(id, completer: completer));
    return completer.future;
  }

  /// Returns `true` if the delete succeeded so the screen can pop.
  Future<bool> delete(String id) {
    final completer = Completer<bool>();
    add(BookmarkDetailDeleteRequested(id, completer: completer));
    return completer.future;
  }

  Future<void> _onLoadRequested(
    BookmarkDetailLoadRequested event,
    Emitter<BookmarkDetailState> emit,
  ) async {
    try {
      emit(const BookmarkDetailState.loading());
      final result = await _get(event.id);
      switch (result) {
        case Ok(value: final bookmark):
          unawaited(
            _analytics.trackBookmarkViewed(
              bookmarkId: bookmark.id,
              tagCount: bookmark.tags.length,
              hasDescription: bookmark.description.isNotEmpty,
            ),
          );
          emit(BookmarkDetailState.ready(bookmark));
        case Err(:final failure):
          emit(BookmarkDetailState.failure(failure));
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  Future<void> _onDeleteRequested(
    BookmarkDetailDeleteRequested event,
    Emitter<BookmarkDetailState> emit,
  ) async {
    try {
      final result = await _delete(event.id);
      switch (result) {
        case Ok<void>():
          unawaited(
            _analytics.trackBookmarkDeleted(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
            ),
          );
          event.completer.completeValueIfPending(true);
        case Err(:final failure):
          unawaited(
            _analytics.trackBookmarkDeleteFailed(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
              errorType: failure.runtimeType.toString(),
            ),
          );
          event.completer.completeValueIfPending(false);
      }
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }
}

sealed class BookmarkDetailEvent {
  const BookmarkDetailEvent();
}

final class BookmarkDetailLoadRequested extends BookmarkDetailEvent {
  const BookmarkDetailLoadRequested(this.id, {this.completer});

  final String id;
  final Completer<void>? completer;
}

final class BookmarkDetailDeleteRequested extends BookmarkDetailEvent {
  const BookmarkDetailDeleteRequested(this.id, {this.completer});

  final String id;
  final Completer<bool>? completer;
}
