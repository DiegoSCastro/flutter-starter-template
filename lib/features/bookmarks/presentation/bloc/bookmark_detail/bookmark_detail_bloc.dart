import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import 'bookmark_detail_state.dart';

part 'bookmark_detail_event.dart';

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
    final completion = stream.firstWhere(
      (state) => state is BookmarkDetailReady || state is BookmarkDetailFailure,
    );
    add(BookmarkDetailLoadRequested(id));
    return completion.then((_) {});
  }

  Future<void> delete(String id) {
    add(BookmarkDetailDeleteRequested(id));
    return Future<void>.delayed(Duration.zero);
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
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _onDeleteRequested(
    BookmarkDetailDeleteRequested event,
    Emitter<BookmarkDetailState> emit,
  ) async {
    try {
      final previous = state;
      if (previous is BookmarkDetailReady) {
        emit(BookmarkDetailState.deleting(previous.bookmark));
      }
      final result = await _delete(event.id);
      switch (result) {
        case Ok<void>():
          unawaited(
            _analytics.trackBookmarkDeleted(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
            ),
          );
          emit(const BookmarkDetailState.deleted());
        case Err(:final failure):
          unawaited(
            _analytics.trackBookmarkDeleteFailed(
              bookmarkId: event.id,
              source: AnalyticsSources.detail,
              errorType: failure.runtimeType.toString(),
            ),
          );
          emit(BookmarkDetailState.failure(failure));
      }
    } catch (_) {
      rethrow;
    }
  }
}
