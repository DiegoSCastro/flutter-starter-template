import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
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
        act: (bloc) => bloc.load('1'),
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
        act: (bloc) => bloc.load('1'),
        expect: () => [
          const BookmarkDetailState.loading(),
          predicate<BookmarkDetailState>((s) => s is BookmarkDetailFailure),
        ],
      );
    });

    group('delete', () {
      test('returns true on success', () async {
        when(() => mockDelete('1')).thenAnswer((_) async => const Ok(null));
        final bloc = BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics);
        final ok = await bloc.delete('1');
        expect(ok, true);
        verify(
          () => mockAnalytics.logEvent(
            'bookmark_deleted',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
        await bloc.close();
      });

      test('returns false on failure', () async {
        when(
          () => mockDelete('1'),
        ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
        final bloc = BookmarkDetailBloc(mockGet, mockDelete, mockAnalytics);
        final ok = await bloc.delete('1');
        expect(ok, false);
        verify(
          () => mockAnalytics.logEvent(
            'bookmark_delete_failed',
            parameters: any(named: 'parameters'),
          ),
        ).called(1);
        await bloc.close();
      });
    });
  });
}
