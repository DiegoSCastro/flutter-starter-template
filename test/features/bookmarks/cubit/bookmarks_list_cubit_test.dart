import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/data/sync/bookmarks_sync_service.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/delete_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/list_bookmarks.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmarks_list_cubit.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmarks_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockListBookmarks extends Mock implements ListBookmarks {}

class MockDeleteBookmark extends Mock implements DeleteBookmark {}

class MockBookmarksSyncService extends Mock implements BookmarksSyncService {}

void main() {
  late MockListBookmarks mockList;
  late MockDeleteBookmark mockDelete;
  late MockBookmarksSyncService mockSync;
  late StreamController<BookmarksSyncStatus> statusController;

  final testBookmark = Bookmark(
    id: '1',
    title: 'Flutter',
    url: 'https://flutter.dev',
    description: 'Flutter website',
    tags: ['dev'],
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final testBookmark2 = Bookmark(
    id: '2',
    title: 'Dart',
    url: 'https://dart.dev',
    description: 'Dart website',
    tags: ['lang'],
    createdAt: DateTime(2025, 1, 2),
    updatedAt: DateTime(2025, 1, 2),
  );

  setUp(() {
    mockList = MockListBookmarks();
    mockDelete = MockDeleteBookmark();
    mockSync = MockBookmarksSyncService();
    statusController = StreamController<BookmarksSyncStatus>.broadcast();
    when(() => mockSync.statusStream).thenAnswer((_) => statusController.stream);
  });

  tearDown(() {
    statusController.close();
  });

  BookmarksListCubit buildCubit() =>
      BookmarksListCubit(mockList, mockDelete, mockSync);

  group('BookmarksListCubit', () {
    test('initial state is empty', () {
      final cubit = buildCubit();
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.query, '');
      cubit.close();
    });

    group('load', () {
      blocTest<BookmarksListCubit, BookmarksListState>(
        'emits loading then items on success',
        setUp: () {
          when(() => mockList()).thenAnswer(
            (_) async => Ok([testBookmark, testBookmark2]),
          );
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading && s.items.isEmpty),
          predicate<BookmarksListState>(
            (s) => !s.isLoading && s.items.length == 2,
          ),
        ],
      );

      blocTest<BookmarksListCubit, BookmarksListState>(
        'emits loading then failure on error',
        setUp: () {
          when(() => mockList()).thenAnswer(
            (_) async => const Err(UnknownFailure('Failed')),
          );
        },
        build: buildCubit,
        act: (cubit) => cubit.load(),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => s.failure != null),
        ],
      );
    });

    group('setQuery', () {
      blocTest<BookmarksListCubit, BookmarksListState>(
        'updates query and filters visibleItems',
        build: buildCubit,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (cubit) => cubit.setQuery('Dart'),
        expect: () => [
          predicate<BookmarksListState>(
            (s) => s.query == 'Dart' && s.visibleItems.length == 1,
          ),
        ],
      );

      blocTest<BookmarksListCubit, BookmarksListState>(
        'does nothing when query is unchanged',
        build: buildCubit,
        seed: () => BookmarksListState(
          items: [testBookmark],
          query: 'flutter',
        ),
        act: (cubit) => cubit.setQuery('flutter'),
        expect: () => <BookmarksListState>[],
      );
    });

    group('delete', () {
      blocTest<BookmarksListCubit, BookmarksListState>(
        'optimistically removes item',
        setUp: () {
          when(() => mockDelete('1')).thenAnswer(
            (_) async => const Ok(null),
          );
        },
        build: buildCubit,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (cubit) => cubit.delete('1'),
        expect: () => [
          predicate<BookmarksListState>((s) => s.items.isEmpty),
        ],
      );

      blocTest<BookmarksListCubit, BookmarksListState>(
        'restores item and reloads on delete failure',
        setUp: () {
          when(() => mockDelete('1')).thenAnswer(
            (_) async => const Err(UnknownFailure('Failed')),
          );
          when(() => mockList()).thenAnswer(
            (_) async => Ok([testBookmark]),
          );
        },
        build: buildCubit,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (cubit) => cubit.delete('1'),
        expect: () => [
          predicate<BookmarksListState>((s) => s.items.isEmpty),
          predicate<BookmarksListState>((s) => s.items.length == 1),
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => !s.isLoading),
        ],
      );
    });
  });
}
