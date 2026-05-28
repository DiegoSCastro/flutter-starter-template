import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../bookmarks/presentation/cubit/bookmarks_list/bookmarks_list_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmarks_list/bookmarks_list_state.dart';
import 'home_state.dart';

@lazySingleton
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._authCubit, this._bookmarksCubit) : super(const HomeState()) {
    _authSub = _authCubit.stream.listen(_onAuthChanged);
    _bookmarksSub = _bookmarksCubit.stream.listen(_onBookmarksChanged);
  }

  final AuthCubit _authCubit;
  final BookmarksListCubit _bookmarksCubit;
  late final StreamSubscription<AuthState> _authSub;
  late final StreamSubscription<BookmarksListState> _bookmarksSub;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    await _bookmarksCubit.load();
    _recompute();
  }

  void _onAuthChanged(AuthState authState) => _recompute();

  void _onBookmarksChanged(BookmarksListState bookmarksState) => _recompute();

  void _recompute() {
    final authState = _authCubit.state;
    final bookmarksState = _bookmarksCubit.state;
    final items = bookmarksState.items;
    final username = authState is AuthAuthenticated
        ? authState.user.username
        : '';
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    emit(
      state.copyWith(
        isLoading: false,
        username: username,
        totalBookmarks: items.length,
        recentBookmarks: items
            .where((b) => b.createdAt.isAfter(weekAgo))
            .length,
        uniqueTags: items.expand((b) => b.tags).toSet().length,
        recentItems: items.take(3).toList(),
      ),
    );
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    _bookmarksSub.cancel();
    return super.close();
  }
}
