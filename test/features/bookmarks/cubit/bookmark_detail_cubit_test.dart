import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_detail/bookmark_detail_cubit.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_detail/bookmark_detail_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_utils.dart';

void main() {
  late MockGetBookmark mockGet;
  late MockDeleteBookmark mockDelete;

  setUp(() {
    mockGet = MockGetBookmark();
    mockDelete = MockDeleteBookmark();
  });

  group('BookmarkDetailCubit', () {
    blocTest<BookmarkDetailCubit, BookmarkDetailState>(
      'initial state is loading',
      build: () => BookmarkDetailCubit(mockGet, mockDelete),
      verify: (cubit) {
        expect(cubit.state, const BookmarkDetailState.loading());
      },
    );

    group('load', () {
      blocTest<BookmarkDetailCubit, BookmarkDetailState>(
        'emits loading then ready on success',
        build: () {
          when(() => mockGet('1')).thenAnswer(
            (_) async => Ok(testBookmark),
          );
          return BookmarkDetailCubit(mockGet, mockDelete);
        },
        act: (cubit) => cubit.load('1'),
        expect: () => [
          const BookmarkDetailState.loading(),
          BookmarkDetailState.ready(testBookmark),
        ],
      );

      blocTest<BookmarkDetailCubit, BookmarkDetailState>(
        'emits loading then failure on error',
        build: () {
          when(() => mockGet('1')).thenAnswer(
            (_) async => const Err(NotFoundFailure('Not found')),
          );
          return BookmarkDetailCubit(mockGet, mockDelete);
        },
        act: (cubit) => cubit.load('1'),
        expect: () => [
          const BookmarkDetailState.loading(),
          predicate<BookmarkDetailState>(
            (s) => s is BookmarkDetailFailure,
          ),
        ],
      );
    });

    group('delete', () {
      test('returns true on success', () async {
        when(() => mockDelete('1')).thenAnswer(
          (_) async => const Ok(null),
        );
        final cubit = BookmarkDetailCubit(mockGet, mockDelete);
        final ok = await cubit.delete('1');
        expect(ok, true);
        cubit.close();
      });

      test('returns false on failure', () async {
        when(() => mockDelete('1')).thenAnswer(
          (_) async => const Err(UnknownFailure('Failed')),
        );
        final cubit = BookmarkDetailCubit(mockGet, mockDelete);
        final ok = await cubit.delete('1');
        expect(ok, false);
        cubit.close();
      });
    });
  });
}
