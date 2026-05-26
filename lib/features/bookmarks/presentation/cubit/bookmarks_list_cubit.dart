import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../domain/usecases/delete_bookmark.dart';
import '../../domain/usecases/list_bookmarks.dart';
import 'bookmarks_list_state.dart';

@lazySingleton
class BookmarksListCubit extends Cubit<BookmarksListState> {
  BookmarksListCubit(this._list, this._delete)
      : super(const BookmarksListState());

  final ListBookmarks _list;
  final DeleteBookmark _delete;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _list();
    switch (result) {
      case Ok(value: final items):
        emit(state.copyWith(isLoading: false, items: items));
      case Err(failure: final failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Updates the search query. Filtering is derived in the state itself
  /// ([BookmarksListState.visibleItems]), so this is a single setState.
  void setQuery(String query) {
    if (query == state.query) return;
    emit(state.copyWith(query: query));
  }

  /// Optimistically removes the row, then issues the DELETE. Reloads on
  /// failure to recover the source-of-truth list.
  Future<void> delete(String id) async {
    final previous = state.items;
    emit(state.copyWith(
      items: previous.where((b) => b.id != id).toList(growable: false),
    ));
    final result = await _delete(id);
    if (result is Err) {
      emit(state.copyWith(items: previous));
      await load();
    }
  }
}
