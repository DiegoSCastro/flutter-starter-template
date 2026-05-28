import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_bloc.dart';
import 'package:flutter_starter_template/features/bookmarks/presentation/bloc/bookmark_form/bookmark_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test_utils.dart';

void main() {
  late MockGetBookmark mockGet;
  late MockCreateBookmark mockCreate;
  late MockUpdateBookmark mockUpdate;
  late MockAnalyticsService mockAnalytics;
  late MockImagePickerService mockImagePicker;

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
    mockAnalytics = MockAnalyticsService();
    mockImagePicker = MockImagePickerService();
    stubAnalyticsService(mockAnalytics);
  });

  BookmarkFormBloc buildBloc() => BookmarkFormBloc(
        mockGet,
        mockCreate,
        mockUpdate,
        mockAnalytics,
        mockImagePicker,
      );

  group('BookmarkFormBloc', () {
    group('initialize', () {
      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'stays idle with empty state for create mode (null id)',
        build: buildBloc,
        act: (bloc) => bloc.initialize(null),
        expect: () => [const BookmarkFormState()],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'loads existing bookmark for edit mode',
        setUp: () {
          when(() => mockGet('1')).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        act: (bloc) => bloc.initialize('1'),
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

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'emits loadFailed when bookmark not found',
        setUp: () {
          when(
            () => mockGet('1'),
          ).thenAnswer((_) async => const Err(NotFoundFailure('Not found')));
        },
        build: buildBloc,
        act: (bloc) => bloc.initialize('1'),
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
      test('setTitle updates title', () async {
        final bloc = buildBloc();
        await bloc.setTitle('Dart');
        expect(bloc.state.title, 'Dart');
        await bloc.close();
      });

      test('setUrl updates url', () async {
        final bloc = buildBloc();
        await bloc.setUrl('https://dart.dev');
        expect(bloc.state.url, 'https://dart.dev');
        await bloc.close();
      });

      test('setDescription updates description', () async {
        final bloc = buildBloc();
        await bloc.setDescription('The Dart language');
        expect(bloc.state.description, 'The Dart language');
        await bloc.close();
      });

      test('setTagsFromCsv parses comma-separated tags', () async {
        final bloc = buildBloc();
        await bloc.setTagsFromCsv('a, b, c ,');
        expect(bloc.state.tags, ['a', 'b', 'c']);
        await bloc.close();
      });

      test('setTagsFromCsv with empty string yields empty list', () async {
        final bloc = buildBloc();
        await bloc.setTagsFromCsv('');
        expect(bloc.state.tags, isEmpty);
        await bloc.close();
      });
    });

    group('submit', () {
      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'creates new bookmark on success',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: ['dev'],
        ),
        act: (bloc) => bloc.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_created',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'updates existing bookmark on success',
        setUp: () {
          when(
            () => mockUpdate(any<UpdateBookmarkParams>()),
          ).thenAnswer((_) async => Ok(testBookmark));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(
          id: '1',
          title: 'Flutter',
          url: 'https://flutter.dev',
          description: 'Flutter website',
          tags: ['dev'],
        ),
        act: (bloc) => bloc.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitted,
          ),
        ],
        verify: (_) {
          verify(
            () => mockAnalytics.logEvent(
              'bookmark_updated',
              parameters: any(named: 'parameters'),
            ),
          ).called(1);
        },
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'returns to idle with failure on error',
        setUp: () {
          when(
            () => mockCreate(any()),
          ).thenAnswer((_) async => const Err(ValidationFailure('Invalid')));
        },
        build: buildBloc,
        seed: () => const BookmarkFormState(title: '.', url: '.'),
        act: (bloc) => bloc.submit(),
        expect: () => [
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.submitting,
          ),
          predicate<BookmarkFormState>(
            (s) => s.status == BookmarkFormStatus.idle && s.failure != null,
          ),
        ],
      );

      blocTest<BookmarkFormBloc, BookmarkFormState>(
        'does nothing when already submitting',
        build: buildBloc,
        seed: () =>
            const BookmarkFormState(status: BookmarkFormStatus.submitting),
        act: (bloc) => bloc.submit(),
        expect: () => <BookmarkFormState>[],
      );
    });
  });
}
