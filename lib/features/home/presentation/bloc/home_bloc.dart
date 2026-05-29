import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/domain/usecases/list_bookmarks.dart';
import 'home_state.dart';

part 'home_event.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._listBookmarks) : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested, transformer: sequential());
  }

  final ListBookmarks _listBookmarks;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isLoading: true,
          username: event.username,
          failure: null,
        ),
      );
      final result = await _listBookmarks();
      switch (result) {
        case Ok(value: final items):
          emit(_recomputedState(items, username: event.username));
        case Err(:final failure):
          emit(
            state.copyWith(
              isLoading: false,
              username: event.username,
              failure: failure,
            ),
          );
      }
    } catch (_) {
      rethrow;
    }
  }

  HomeState _recomputedState(List<Bookmark> items, {required String username}) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return state.copyWith(
      isLoading: false,
      failure: null,
      username: username,
      totalBookmarks: items.length,
      recentBookmarks: items.where((b) => b.createdAt.isAfter(weekAgo)).length,
      uniqueTags: items.expand((b) => b.tags).toSet().length,
      recentItems: items.take(3).toList(growable: false),
    );
  }
}
