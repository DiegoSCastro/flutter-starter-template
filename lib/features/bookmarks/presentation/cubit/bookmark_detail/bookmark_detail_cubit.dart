import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_events.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/usecases/delete_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import 'bookmark_detail_state.dart';

@injectable
class BookmarkDetailCubit extends Cubit<BookmarkDetailState> {
  BookmarkDetailCubit(this._get, this._delete, this._analytics)
    : super(const BookmarkDetailState.loading());

  final GetBookmark _get;
  final DeleteBookmark _delete;
  final AnalyticsService _analytics;

  Future<void> load(String id) async {
    emit(const BookmarkDetailState.loading());
    final result = await _get(id);
    switch (result) {
      case Ok(value: final bookmark):
        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.bookmarkViewed,
            parameters: {
              AnalyticsParams.bookmarkId: bookmark.id,
              AnalyticsParams.tagCount: bookmark.tags.length,
              AnalyticsParams.hasDescription: bookmark.description.isNotEmpty
                  ? 1
                  : 0,
            },
          ),
        );
        emit(BookmarkDetailState.ready(bookmark));
      case Err(failure: final failure):
        emit(BookmarkDetailState.failure(failure));
    }
  }

  /// Returns `true` if the delete succeeded so the screen can pop.
  Future<bool> delete(String id) async {
    final result = await _delete(id);
    switch (result) {
      case Ok<void>():
        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.bookmarkDeleted,
            parameters: {
              AnalyticsParams.bookmarkId: id,
              AnalyticsParams.source: AnalyticsSources.detail,
            },
          ),
        );
        return true;
      case Err(failure: final failure):
        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.bookmarkDeleteFailed,
            parameters: {
              AnalyticsParams.bookmarkId: id,
              AnalyticsParams.source: AnalyticsSources.detail,
              AnalyticsParams.errorType: failure.runtimeType.toString(),
            },
          ),
        );
        return false;
    }
  }
}
