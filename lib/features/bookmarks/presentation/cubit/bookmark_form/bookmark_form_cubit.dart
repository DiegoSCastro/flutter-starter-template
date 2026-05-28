import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_events.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../domain/usecases/create_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import '../../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_state.dart';

@injectable
class BookmarkFormCubit extends Cubit<BookmarkFormState> {
  BookmarkFormCubit(this._get, this._create, this._update, this._analytics)
    : super(const BookmarkFormState());

  final GetBookmark _get;
  final CreateBookmark _create;
  final UpdateBookmark _update;
  final AnalyticsService _analytics;

  /// For create flows, pass `null`. For edit flows, fetches the existing
  /// bookmark and seeds the form.
  Future<void> initialize(String? id) async {
    if (id == null) {
      emit(const BookmarkFormState());
      return;
    }
    emit(state.copyWith(id: id, status: BookmarkFormStatus.loading));
    final result = await _get(id);
    switch (result) {
      case Ok(value: final b):
        emit(
          BookmarkFormState(
            id: b.id,
            status: BookmarkFormStatus.idle,
            title: b.title,
            url: b.url,
            description: b.description,
            tags: List.of(b.tags),
          ),
        );
      case Err(failure: final failure):
        emit(
          state.copyWith(
            status: BookmarkFormStatus.loadFailed,
            failure: failure,
          ),
        );
    }
  }

  void setTitle(String value) => emit(state.copyWith(title: value));
  void setUrl(String value) => emit(state.copyWith(url: value));
  void setDescription(String value) => emit(state.copyWith(description: value));
  void setTagsFromCsv(String csv) {
    final parsed = csv
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
    emit(state.copyWith(tags: parsed));
  }

  /// Returns `true` if submit succeeded so the screen can pop.
  Future<bool> submit() async {
    if (state.status == BookmarkFormStatus.submitting) return false;
    emit(state.copyWith(status: BookmarkFormStatus.submitting, failure: null));

    final input = BookmarkInput(
      title: state.title.trim(),
      url: state.url.trim(),
      description: state.description.trim(),
      tags: state.tags,
    );
    final isEditing = state.id != null;
    final result = !isEditing
        ? await _create(input)
        : await _update((id: state.id!, input: input));

    switch (result) {
      case Ok(value: final bookmark):
        unawaited(
          _analytics.logEvent(
            isEditing
                ? AnalyticsEvents.bookmarkUpdated
                : AnalyticsEvents.bookmarkCreated,
            parameters: {
              AnalyticsParams.bookmarkId: bookmark.id,
              AnalyticsParams.tagCount: bookmark.tags.length,
              AnalyticsParams.hasDescription: bookmark.description.isNotEmpty
                  ? 1
                  : 0,
            },
          ),
        );
        emit(state.copyWith(status: BookmarkFormStatus.submitted));
        return true;
      case Err(failure: final failure):
        emit(state.copyWith(status: BookmarkFormStatus.idle, failure: failure));
        return false;
    }
  }
}
