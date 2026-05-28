import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';

abstract interface class BookmarksRepository {
  Future<Result<List<Bookmark>>> list();
  Future<Result<Bookmark>> get(String id);
  Future<Result<Bookmark>> create(BookmarkInput input);
  Future<Result<Bookmark>> update(String id, BookmarkInput input);
  Future<Result<void>> delete(String id);
}
