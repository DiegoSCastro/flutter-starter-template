import 'package:bloc_test/bloc_test.dart';
import 'package:core_domain/core_domain.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_detail/bookmark_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test_utils.dart';

void main() {
  late MockGetBookmark mockGet;
  late MockDeleteBookmark mockDelete;
  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockGet = MockGetBookmark();
    mockDelete = MockDeleteBookmark();
    mockAnalytics = MockAnalyticsService();
    stubAnalyticsService(mockAnalytics);
  });

  group('BookmarkDetailBloc', () {
    blocTest<BookmarkDetailBloc, BookmarkDetailState>(
      'initial state is loading',
      build: () => BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics),
      verify: (bloc) {
        expect(bloc.state, const BookmarkDetailState.loading());
      },
    );

    group('load', () {
      blocTest<BookmarkDetailBloc, BookmarkDetailState>(
        'emits loading then ready on success',
        build: () {
          when(() => mockGet('1')).thenAnswer((_) async => Ok(testBookmark));
          return BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics);
        },
        act: (bloc) => bloc.add(const BookmarkDetailLoadRequested('1')),
        expect: () => [
          const BookmarkDetailState.loading(),
          BookmarkDetailState.ready(testBookmark),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_viewed',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkDetailBloc, BookmarkDetailState>(
        'emits loading then failure on error',
        build: () {
          when(
            () => mockGet('1'),
          ).thenAnswer((_) async => const Err(NotFoundFailure('Not found')));
          return BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics);
        },
        act: (bloc) => bloc.add(const BookmarkDetailLoadRequested('1')),
        expect: () => [
          const BookmarkDetailState.loading(),
          predicate<BookmarkDetailState>((s) => s is BookmarkDetailFailure),
        ],
      );
    });

    group('delete', () {
      blocTest<BookmarkDetailBloc, BookmarkDetailState>(
        'emits deleting then deleted on success',
        setUp: () {
          when(() => mockDelete('1')).thenAnswer((_) async => const Ok(null));
        },
        build: () => BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics),
        seed: () => BookmarkDetailState.ready(testBookmark),
        act: (bloc) => bloc.add(const BookmarkDetailDeleteRequested('1')),
        expect: () => [
          BookmarkDetailState.deleting(testBookmark),
          const BookmarkDetailState.deleted(),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_deleted',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkDetailBloc, BookmarkDetailState>(
        'emits deleting then failure on failure',
        setUp: () {
          when(
            () => mockDelete('1'),
          ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
        },
        build: () => BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics),
        seed: () => BookmarkDetailState.ready(testBookmark),
        act: (bloc) => bloc.add(const BookmarkDetailDeleteRequested('1')),
        expect: () => [
          BookmarkDetailState.deleting(testBookmark),
          predicate<BookmarkDetailState>((s) => s is BookmarkDetailFailure),
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
