import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  group('HomeBloc', () {
    test('initial state is default', () async {
      final bloc = HomeBloc(_authRepository(), MockListBookmarks());

      expect(bloc.state.username, '');
      expect(bloc.state.totalBookmarks, 0);
      expect(bloc.state.recentBookmarks, 0);
      expect(bloc.state.uniqueTags, 0);
      expect(bloc.state.recentItems, isEmpty);
      expect(bloc.state.isLoading, false);

      await bloc.close();
    });

    test('aggregates auth and bookmark data on load', () async {
      final listBookmarks = _listBookmarks(Ok([testBookmark, testBookmark2]));
      final bloc = HomeBloc(
        _authRepository(currentUser: testUser),
        listBookmarks,
      );

      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.username, 'alice');
      expect(bloc.state.totalBookmarks, 2);
      expect(bloc.state.uniqueTags, 2);
      expect(bloc.state.recentItems.length, 2);

      await bloc.close();
    });

    test('handles empty bookmarks', () async {
      final bloc = HomeBloc(_authRepository(), _listBookmarks(const Ok([])));
      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.totalBookmarks, 0);
      expect(bloc.state.recentBookmarks, 0);
      expect(bloc.state.uniqueTags, 0);
      expect(bloc.state.recentItems, isEmpty);

      await bloc.close();
    });

    test('stores failure when bookmark load fails', () async {
      const failure = UnknownFailure('Failed');
      final bloc = HomeBloc(
        _authRepository(currentUser: testUser),
        _listBookmarks(const Err(failure)),
      );

      bloc.add(const HomeLoadRequested());
      await bloc.stream.firstWhere((state) => !state.isLoading);

      expect(bloc.state.username, 'alice');
      expect(bloc.state.isLoading, false);
      expect(bloc.state.failure, failure);

      await bloc.close();
    });
  });
}

MockAuthRepository _authRepository({AuthUser? currentUser}) {
  final repository = MockAuthRepository();
  when(() => repository.currentUser).thenReturn(currentUser);
  return repository;
}

MockListBookmarks _listBookmarks(Result<List<Bookmark>> result) {
  final listBookmarks = MockListBookmarks();
  when(listBookmarks.call).thenAnswer((_) async => result);
  return listBookmarks;
}
