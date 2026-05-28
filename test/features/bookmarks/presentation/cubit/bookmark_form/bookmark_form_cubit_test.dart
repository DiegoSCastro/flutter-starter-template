import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_form/bookmark_form_cubit.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/cubit/bookmark_form/bookmark_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test_utils.dart';

void main() {
  late MockGetBookmark mockGet;
  late MockCreateBookmark mockCreate;
  late MockUpdateBookmark mockUpdate;

  setUpAll(() {
    registerFallbackValue(FakeBookmarkInput());
    final UpdateBookmarkParams fallbackUpdateParams = (
      id: '',
      input: FakeBookmarkInput(),
    );
    registerFallbackValue(fallbackUpdateParams);
  });

  setUp(() {
    mockGet = MockGetBookmark();
    mockCreate = MockCreateBookmark();
    mockUpdate = MockUpdateBookmark();
  });

  BookmarkFormCubit buildCubit() =>
      BookmarkFormCubit(mockGet, mockCreate, mockUpdate);

  group('BookmarkFormCubit', () {
    group('initialize', () {
      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'stays idle with empty state for create mode (null id)',
        build: buildCubit,
        act: (cubit) => cubit.initialize(null),
        expect: () => [const BookmarkFormState()],
      );

      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'loads existing bookmark for edit mode',
        setUp: () {
          when(() => mockGet('1')).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildCubit,
        act: (cubit) => cubit.initialize('1'),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loading,
          ),
          predicate<BookmarkFormState>(
            (s) =>
                s.status == BookmarkFormStatus.idle &&
                s.title == 'Flutter' &&
                s.url == 'https://flutter.dev',
          ),
        ],
      );

      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'emits loadFailed when bookmark not found',
        setUp: () {
          when(
            () => mockGet('1'),
          ).thenAnswer((_) async => const Err(NotFoundFailure('Not found')));
        },
        build: buildCubit,
        act: (cubit) => cubit.initialize('1'),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loading,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.loadFailed,
          ),
        ],
      );
    });

    group('field setters', () {
      test('setTitle updates title', () {
        final cubit = buildCubit();
        cubit.setTitle('Dart');
        expect(cubit.state.title, 'Dart');
        cubit.close();
      });

      test('setUrl updates url', () {
        final cubit = buildCubit();
        cubit.setUrl('https://dart.dev');
        expect(cubit.state.url, 'https://dart.dev');
        cubit.close();
      });

      test('setDescription updates description', () {
        final cubit = buildCubit();
        cubit.setDescription('The Dart language');
        expect(cubit.state.description, 'The Dart language');
        cubit.close();
      });

      test('setTagsFromCsv parses comma-separated tags', () {
        final cubit = buildCubit();
        cubit.setTagsFromCsv('a, b, c ,');
        expect(cubit.state.tags, ['a', 'b', 'c']);
        cubit.close();
      });

      test('setTagsFromCsv with empty string yields empty list', () {
        final cubit = buildCubit();
        cubit.setTagsFromCsv('');
        expect(cubit.state.tags, isEmpty);
        cubit.close();
      });
    });

    group('submit', () {
      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'creates new bookmark on success',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildCubit,
        seed: () => BookmarkFormState(
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: const ['dev'],
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
      );

      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'updates existing bookmark on success',
        setUp: () {
          when(
            () => mockUpdate(any<UpdateBookmarkParams>()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildCubit,
        seed: () => BookmarkFormState(
          id: '1',
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: const ['dev'],
        ),
        act: (cubit) => cubit.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
      );

      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'returns to idle with failure on error',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => const Err(ValidationFailure('Invalid')));
        },
        build: buildCubit,
        seed: () => BookmarkFormState(title: '.', url: '.'),
        act: (cubit) => cubit.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.idle && s.failure != null,
          ),
        ],
      );

      blocTest<BookmarkFormCubit, BookmarkFormState>(
        'does nothing when already submitting',
        build: buildCubit,
        seed: () => BookmarkFormState(status: BookmarkFormStatus.submitting),
        act: (cubit) => cubit.submit(),
        expect: () => <BookmarkFormState>[],
      );
    });
  });
}
