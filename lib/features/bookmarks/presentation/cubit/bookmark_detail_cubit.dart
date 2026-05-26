import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/usecases/delete_bookmark.dart';
import '../../domain/usecases/get_bookmark.dart';
import 'bookmark_detail_state.dart';

@injectable
class BookmarkDetailCubit extends Cubit<BookmarkDetailState> {
  BookmarkDetailCubit(this._get, this._delete)
      : super(const BookmarkDetailState.loading());

  final GetBookmark _get;
  final DeleteBookmark _delete;

  Future<void> load(String id) async {
    emit(const BookmarkDetailState.loading());
    final result = await _get(id);
    switch (result) {
      case Ok(value: final bookmark):
        emit(BookmarkDetailState.ready(bookmark));
      case Err(failure: final failure):
        emit(BookmarkDetailState.failure(failure));
    }
  }

  /// Returns `true` if the delete succeeded so the screen can pop.
  Future<bool> delete(String id) async {
    final result = await _delete(id);
    return result is Ok<void>;
  }
}
