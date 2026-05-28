import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/analytics/analytics_extensions.dart';
import '../../../../../core/analytics/analytics_service.dart';
import '../../../../../core/bloc/event_completion.dart';
import '../../../../../core/utils/result.dart';
import '../../../domain/entities/bookmark.dart';
import '../../../domain/usecases/create_bookmark.dart';
import '../../../domain/usecases/get_bookmark.dart';
import '../../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_state.dart';

@injectable
class BookmarkFormBloc extends Bloc<BookmarkFormEvent, BookmarkFormState> {
  BookmarkFormBloc(this._get, this._create, this._update, this._analytics)
    : super(const BookmarkFormState()) {
    on<BookmarkFormInitialized>(_onInitialized, transformer: sequential());
    on<BookmarkFormTitleChanged>(_onTitleChanged, transformer: sequential());
    on<BookmarkFormUrlChanged>(_onUrlChanged, transformer: sequential());
    on<BookmarkFormDescriptionChanged>(
      _onDescriptionChanged,
      transformer: sequential(),
    );
    on<BookmarkFormTagsChanged>(_onTagsChanged, transformer: sequential());
    on<BookmarkFormSubmitted>(_onSubmitted, transformer: sequential());
  }

  final GetBookmark _get;
  final CreateBookmark _create;
  final UpdateBookmark _update;
  final AnalyticsService _analytics;
  bool _submitInFlight = false;

  /// For create flows, pass `null`. For edit flows, fetches the existing
  /// bookmark and seeds the form.
  Future<void> initialize(String? id) {
    final completer = Completer<void>();
    add(BookmarkFormInitialized(id, completer: completer));
    return completer.future;
  }

  Future<void> setTitle(String value) {
    final completer = Completer<void>();
    add(BookmarkFormTitleChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setUrl(String value) {
    final completer = Completer<void>();
    add(BookmarkFormUrlChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setDescription(String value) {
    final completer = Completer<void>();
    add(BookmarkFormDescriptionChanged(value, completer: completer));
    return completer.future;
  }

  Future<void> setTagsFromCsv(String csv) {
    final completer = Completer<void>();
    add(BookmarkFormTagsChanged(csv, completer: completer));
    return completer.future;
  }

  /// Returns `true` if submit succeeded so the screen can pop.
  Future<bool> submit() {
    if (state.status == BookmarkFormStatus.submitting || _submitInFlight) {
      return Future<bool>.value(false);
    }
    _submitInFlight = true;
    final completer = Completer<bool>();
    add(BookmarkFormSubmitted(completer: completer));
    return completer.future.whenComplete(() => _submitInFlight = false);
  }

  Future<void> _onInitialized(
    BookmarkFormInitialized event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      final id = event.id;
      if (id == null) {
        emit(const BookmarkFormState());
        event.completer.completeVoidIfPending();
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
        case Err(:final failure):
          emit(
            state.copyWith(
              status: BookmarkFormStatus.loadFailed,
              failure: failure,
            ),
          );
      }
      event.completer.completeVoidIfPending();
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }

  void _onTitleChanged(
    BookmarkFormTitleChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(title: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onUrlChanged(
    BookmarkFormUrlChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(url: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onDescriptionChanged(
    BookmarkFormDescriptionChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    emit(state.copyWith(description: event.value));
    event.completer.completeVoidIfPending();
  }

  void _onTagsChanged(
    BookmarkFormTagsChanged event,
    Emitter<BookmarkFormState> emit,
  ) {
    final parsed = event.csv
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
    emit(state.copyWith(tags: parsed));
    event.completer.completeVoidIfPending();
  }

  Future<void> _onSubmitted(
    BookmarkFormSubmitted event,
    Emitter<BookmarkFormState> emit,
  ) async {
    try {
      if (state.status == BookmarkFormStatus.submitting) {
        event.completer.completeValueIfPending(false);
        return;
      }
      emit(
        state.copyWith(status: BookmarkFormStatus.submitting, failure: null),
      );

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
          final trackChange = isEditing
              ? _analytics.trackBookmarkUpdated
              : _analytics.trackBookmarkCreated;
          unawaited(
            trackChange(
              bookmarkId: bookmark.id,
              tagCount: bookmark.tags.length,
              hasDescription: bookmark.description.isNotEmpty,
            ),
          );
          emit(state.copyWith(status: BookmarkFormStatus.submitted));
          event.completer.completeValueIfPending(true);
        case Err(:final failure):
          emit(
            state.copyWith(status: BookmarkFormStatus.idle, failure: failure),
          );
          event.completer.completeValueIfPending(false);
      }
    } catch (error, stackTrace) {
      event.completer.completeErrorIfPending(error, stackTrace);
      rethrow;
    }
  }
}

sealed class BookmarkFormEvent {
  const BookmarkFormEvent();
}

final class BookmarkFormInitialized extends BookmarkFormEvent {
  const BookmarkFormInitialized(this.id, {this.completer});

  final String? id;
  final Completer<void>? completer;
}

final class BookmarkFormTitleChanged extends BookmarkFormEvent {
  const BookmarkFormTitleChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormUrlChanged extends BookmarkFormEvent {
  const BookmarkFormUrlChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormDescriptionChanged extends BookmarkFormEvent {
  const BookmarkFormDescriptionChanged(this.value, {this.completer});

  final String value;
  final Completer<void>? completer;
}

final class BookmarkFormTagsChanged extends BookmarkFormEvent {
  const BookmarkFormTagsChanged(this.csv, {this.completer});

  final String csv;
  final Completer<void>? completer;
}

final class BookmarkFormSubmitted extends BookmarkFormEvent {
  const BookmarkFormSubmitted({this.completer});

  final Completer<bool>? completer;
}
