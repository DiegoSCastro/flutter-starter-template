import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/entities/bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/repositories/bookmarks_repository.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/create_bookmark.dart';
import 'package:flutter_starter_template/features/bookmarks/domain/usecases/update_bookmark.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBookmarksRepository extends Mock implements BookmarksRepository {}

class _FakeBookmarkInput extends Fake implements BookmarkInput {}

void main() {
  late _MockBookmarksRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakeBookmarkInput());
  });

  setUp(() {
    repo = _MockBookmarksRepository();
  });

  group('CreateBookmark', () {
    test('rejects empty title without hitting repository', () async {
      final result = await CreateBookmark(repo)(
        const BookmarkInput(
          title: '',
          url: 'https://flutter.dev',
          description: '',
          tags: [],
        ),
      );

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      expect(err.failure.message, 'Title is required.');
      verifyZeroInteractions(repo);
    });

    test('rejects empty url without hitting repository', () async {
      final result = await CreateBookmark(repo)(
        const BookmarkInput(
          title: 'Flutter',
          url: '',
          description: '',
          tags: [],
        ),
      );

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      expect(err.failure.message, 'URL is required.');
      verifyZeroInteractions(repo);
    });
  });

  group('UpdateBookmark', () {
    test('rejects empty title without hitting repository', () async {
      final result = await UpdateBookmark(repo)((
        id: 'b-1',
        input: const BookmarkInput(
          title: '',
          url: 'https://flutter.dev',
          description: '',
          tags: [],
        ),
      ));

      expect(result, isA<Err<Bookmark>>());
      final err = result as Err<Bookmark>;
      expect(err.failure, isA<ValidationFailure>());
      verifyZeroInteractions(repo);
    });
  });
}
