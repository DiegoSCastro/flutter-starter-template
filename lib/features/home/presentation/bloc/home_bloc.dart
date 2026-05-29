import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/domain/usecases/list_bookmarks.dart';
import 'home_state.dart';

part 'home_event.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._authRepository, this._listBookmarks)
    : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoadRequested, transformer: sequential());
  }

  final AuthRepository _authRepository;
  final ListBookmarks _listBookmarks;

  Future<void> load() {
    final completion = stream.firstWhere((state) => !state.isLoading);
    add(const HomeLoadRequested());
    return completion.then((_) {});
  }

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, failure: null));
      final result = await _listBookmarks();
      switch (result) {
        case Ok(value: final items):
          emit(_recomputedState(items));
        case Err(:final failure):
          emit(
            state.copyWith(
              isLoading: false,
              username: _authRepository.currentUser?.username ?? '',
              failure: failure,
            ),
          );
      }
    } catch (_) {
      rethrow;
    }
  }

  HomeState _recomputedState(List<Bookmark> items) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return state.copyWith(
      isLoading: false,
      failure: null,
      username: _authRepository.currentUser?.username ?? '',
      totalBookmarks: items.length,
      recentBookmarks: items.where((b) => b.createdAt.isAfter(weekAgo)).length,
      uniqueTags: items.expand((b) => b.tags).toSet().length,
      recentItems: items.take(3).toList(growable: false),
    );
  }
}
