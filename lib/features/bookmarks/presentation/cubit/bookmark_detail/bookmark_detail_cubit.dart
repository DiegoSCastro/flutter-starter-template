import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
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
          _analytics.trackBookmarkViewed(
            bookmarkId: bookmark.id,
            tagCount: bookmark.tags.length,
            hasDescription: bookmark.description.isNotEmpty,
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
          _analytics.trackBookmarkDeleted(
            bookmarkId: id,
            source: AnalyticsSources.detail,
          ),
        );
        return true;
      case Err(failure: final failure):
        unawaited(
          _analytics.trackBookmarkDeleteFailed(
            bookmarkId: id,
            source: AnalyticsSources.detail,
            errorType: failure.runtimeType.toString(),
          ),
        );
        return false;
    }
  }
}
