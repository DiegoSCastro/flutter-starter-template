import 'dart:async';

import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmarks_list/bookmarks_list_cubit.dart';
import 'package:flutter_starter_template/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_utils.dart';

void main() {
  group('HomeCubit', () {
    test('initial state is default', () async {
      final authCubit = _authCubit();
      final bookmarksCubit = _bookmarksCubit();
      final cubit = HomeCubit(authCubit, bookmarksCubit);

      expect(cubit.state.username, '');
      expect(cubit.state.totalBookmarks, 0);
      expect(cubit.state.recentBookmarks, 0);
      expect(cubit.state.uniqueTags, 0);
      expect(cubit.state.recentItems, isEmpty);
      expect(cubit.state.isLoading, false);

      await cubit.close();
      await bookmarksCubit.close();
      await authCubit.close();
    });

    test('aggregates auth and bookmark data on load', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn(username: 'alice', password: 'pass'),
      ).thenAnswer((_) async => const Ok(testUser));

      final mockList = MockListBookmarks();
      when(
        () => mockList(),
      ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));

      final authCubit = _authCubit(signIn: mockSignIn);
      final bookmarksCubit = BookmarksListCubit(
        mockList,
        MockDeleteBookmark(),
        _mockSync(),
      );

      await authCubit.signIn(username: 'alice', password: 'pass');

      final cubit = HomeCubit(authCubit, bookmarksCubit);
      await cubit.load();

      expect(cubit.state.username, 'alice');
      expect(cubit.state.totalBookmarks, 2);
      expect(cubit.state.uniqueTags, 2);
      expect(cubit.state.recentItems.length, 2);

      await cubit.close();
      await bookmarksCubit.close();
      await authCubit.close();
    });

    test('handles empty bookmarks', () async {
      final cubit = HomeCubit(_authCubit(), _bookmarksCubit());
      await cubit.load();

      expect(cubit.state.totalBookmarks, 0);
      expect(cubit.state.recentBookmarks, 0);
      expect(cubit.state.uniqueTags, 0);
      expect(cubit.state.recentItems, isEmpty);

      await cubit.close();
    });

    test('reacts to stream changes', () async {
      final mockSignIn = MockSignIn();
      when(
        () => mockSignIn(username: 'alice', password: 'pass'),
      ).thenAnswer((_) async => const Ok(testUser));

      final mockList = MockListBookmarks();
      when(() => mockList()).thenAnswer((_) async => const Ok([]));

      final authCubit = _authCubit(signIn: mockSignIn);
      final bookmarksCubit = BookmarksListCubit(
        mockList,
        MockDeleteBookmark(),
        _mockSync(),
      );
      final cubit = HomeCubit(authCubit, bookmarksCubit);

      when(
        () => mockList(),
      ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));
      await authCubit.signIn(username: 'alice', password: 'pass');
      await bookmarksCubit.load();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(cubit.state.username, 'alice');
      expect(cubit.state.totalBookmarks, 2);
      expect(cubit.state.recentItems.length, 2);

      await cubit.close();
      await bookmarksCubit.close();
      await authCubit.close();
    });
  });
}

AuthCubit _authCubit({MockSignIn? signIn}) => AuthCubit(
  signIn: signIn ?? MockSignIn(),
  signOut: MockSignOut(),
  restoreSession: MockRestoreSession(),
);

BookmarksListCubit _bookmarksCubit() {
  final mockList = MockListBookmarks();
  when(() => mockList()).thenAnswer((_) async => const Ok([]));
  return BookmarksListCubit(mockList, MockDeleteBookmark(), _mockSync());
}

BookmarksSyncController _mockSync() {
  final mockSync = MockBookmarksSyncController();
  final sc = StreamController<BookmarksSyncStatus>.broadcast();
  when(() => mockSync.statusStream).thenAnswer((_) => sc.stream);
  return mockSync;
}
