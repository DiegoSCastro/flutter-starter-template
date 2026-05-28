import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/domain/usecases/list_bookmarks.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._authRepository, this._listBookmarks)
    : super(const HomeState());

  final AuthRepository _authRepository;
  final ListBookmarks _listBookmarks;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await _listBookmarks();
    switch (result) {
      case Ok(value: final items):
        _recompute(items);
      case Err(: final failure):
        emit(
          state.copyWith(
            isLoading: false,
            username: _authRepository.currentUser?.username ?? '',
            failure: failure,
          ),
        );
    }
  }

  void _recompute(List<Bookmark> items) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    emit(
      state.copyWith(
        isLoading: false,
        failure: null,
        username: _authRepository.currentUser?.username ?? '',
        totalBookmarks: items.length,
        recentBookmarks: items
            .where((b) => b.createdAt.isAfter(weekAgo))
            .length,
        uniqueTags: items.expand((b) => b.tags).toSet().length,
        recentItems: items.take(3).toList(growable: false),
      ),
    );
  }
}
