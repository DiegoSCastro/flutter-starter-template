import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils.dart';

void main() {
  group('HomeCubit', () {
    test('initial state is default', () async {
      final cubit = HomeCubit(_authRepository(), MockListBookmarks());

      expect(cubit.state.username, '');
      expect(cubit.state.totalBookmarks, 0);
      expect(cubit.state.recentBookmarks, 0);
      expect(cubit.state.uniqueTags, 0);
      expect(cubit.state.recentItems, isEmpty);
      expect(cubit.state.isLoading, false);

      await cubit.close();
    });

    test('aggregates auth and bookmark data on load', () async {
      final listBookmarks = _listBookmarks(Ok([testBookmark, testBookmark2]));
      final cubit = HomeCubit(
        _authRepository(currentUser: testUser),
        listBookmarks,
      );

      await cubit.load();

      expect(cubit.state.username, 'alice');
      expect(cubit.state.totalBookmarks, 2);
      expect(cubit.state.uniqueTags, 2);
      expect(cubit.state.recentItems.length, 2);

      await cubit.close();
    });

    test('handles empty bookmarks', () async {
      final cubit = HomeCubit(_authRepository(), _listBookmarks(const Ok([])));
      await cubit.load();

      expect(cubit.state.totalBookmarks, 0);
      expect(cubit.state.recentBookmarks, 0);
      expect(cubit.state.uniqueTags, 0);
      expect(cubit.state.recentItems, isEmpty);

      await cubit.close();
    });

    test('stores failure when bookmark load fails', () async {
      const failure = UnknownFailure('Failed');
      final cubit = HomeCubit(
        _authRepository(currentUser: testUser),
        _listBookmarks(const Err(failure)),
      );

      await cubit.load();

      expect(cubit.state.username, 'alice');
      expect(cubit.state.isLoading, false);
      expect(cubit.state.failure, failure);

      await cubit.close();
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
  when(() => listBookmarks()).thenAnswer((_) async => result);
  return listBookmarks;
}
