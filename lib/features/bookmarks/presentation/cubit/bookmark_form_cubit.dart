import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../../domain/usecases/create_bookmark.dart';
import '../../domain/usecases/get_bookmark.dart';
import '../../domain/usecases/update_bookmark.dart';
import 'bookmark_form_state.dart';

@injectable
class BookmarkFormCubit extends Cubit<BookmarkFormState> {
  BookmarkFormCubit(this._get, this._create, this._update)
      : super(const BookmarkFormState());

  final GetBookmark _get;
  final CreateBookmark _create;
  final UpdateBookmark _update;

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
        emit(BookmarkFormState(
          id: b.id,
          status: BookmarkFormStatus.idle,
          title: b.title,
          url: b.url,
          description: b.description,
          tags: List.of(b.tags),
        ));
      case Err(failure: final failure):
        emit(state.copyWith(
          status: BookmarkFormStatus.loadFailed,
          failure: failure,
        ));
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
    final result = state.id == null
        ? await _create(input)
        : await _update(state.id!, input);

    switch (result) {
      case Ok():
        emit(state.copyWith(status: BookmarkFormStatus.submitted));
        return true;
      case Err(failure: final failure):
        emit(state.copyWith(
          status: BookmarkFormStatus.idle,
          failure: failure,
        ));
        return false;
    }
  }
}
