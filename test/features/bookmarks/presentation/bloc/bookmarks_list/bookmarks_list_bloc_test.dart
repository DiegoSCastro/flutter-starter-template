import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/services/bookmarks_sync_controller.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmarks_list/bookmarks_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test_utils.dart';

void main() {
  late MockListBookmarks mockList;
  late MockDeleteBookmark mockDelete;
  late MockBookmarksSyncController mockSync;
  late MockAnalyticsService mockAnalytics;
  late StreamController<BookmarksSyncStatus> statusController;

  setUp(() {
    mockList = MockListBookmarks();
    mockDelete = MockDeleteBookmark();
    mockSync = MockBookmarksSyncController();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
    statusController = StreamController<BookmarksSyncStatus>.broadcast();
    when(
      () => mockSync.statusStream,
    ).thenAnswer((_) => statusController.stream);
  });

  tearDown(() {
    statusController.close();
  });

  BookmarksListBloc buildBloc() =>
      BookmarksListBloc(mockList, mockDelete, mockSync, mockAnalytics);

  group('BookmarksListBloc', () {
    test('initial state is empty', () {
      final bloc = buildBloc();
      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isLoading, false);
      expect(bloc.state.query, '');
      bloc.close();
    });

    group('load', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'emits loading then items on success',
        setUp: () {
          when(
            () => mockList(),
          ).thenAnswer((_) async => Ok([testBookmark, testBookmark2]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarksListLoadRequested()),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading && s.items.isEmpty),
          predicate<BookmarksListState>(
            (s) => !s.isLoading && s.items.length == 2,
          ),
        ],
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'emits loading then failure on error',
        setUp: () {
          when(
            () => mockList(),
          ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const BookmarksListLoadRequested()),
        expect: () => [
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => s.failure != null),
        ],
      );
    });

    group('setQuery', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'updates query and filters visibleItems',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark, testBookmark2]),
        act: (bloc) => bloc.add(const BookmarksListQueryChanged('Dart')),
        expect: () => [
          predicate<BookmarksListState>(
            (s) => s.query == 'Dart' && s.visibleItems.length == 1,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_search',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'does nothing when query is unchanged',
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark], query: 'flutter'),
        act: (bloc) => bloc.add(const BookmarksListQueryChanged('flutter')),
        expect: () => <BookmarksListState>[],
      );
    });

    group('delete', () {
      blocTest<BookmarksListBloc, BookmarksListState>(
        'optimistically removes item',
        setUp: () {
          when(() => mockDelete('1')).thenAnswer((_) async => const Ok(null));
        },
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (bloc) => bloc.add(const BookmarksListDeleteRequested('1')),
        expect: () => [predicate<BookmarksListState>((s) => s.items.isEmpty)],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_deleted',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarksListBloc, BookmarksListState>(
        'restores item and reloads on delete failure',
        setUp: () {
          when(
            () => mockDelete('1'),
          ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
          when(() => mockList()).thenAnswer((_) async => Ok([testBookmark]));
        },
        build: buildBloc,
        seed: () => BookmarksListState(items: [testBookmark]),
        act: (bloc) => bloc.add(const BookmarksListDeleteRequested('1')),
        expect: () => [
          predicate<BookmarksListState>((s) => s.items.isEmpty),
          predicate<BookmarksListState>((s) => s.items.length == 1),
          predicate<BookmarksListState>((s) => s.isLoading),
          predicate<BookmarksListState>((s) => !s.isLoading),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_delete_failed',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );
    });
  });
}
