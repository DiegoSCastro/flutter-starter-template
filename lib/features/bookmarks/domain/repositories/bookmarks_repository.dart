import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';

class BookmarkInput {
  const BookmarkInput({
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
  });

  final String title;
  final String url;
  final String description;
  final List<String> tags;
}

abstract interface class BookmarksRepository {
  Future<Result<List<Bookmark>>> list();
  Future<Result<Bookmark>> get(String id);
  Future<Result<Bookmark>> create(BookmarkInput input);
  Future<Result<Bookmark>> update(String id, BookmarkInput input);
  Future<Result<void>> delete(String id);
}
