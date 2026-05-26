import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class UpdateBookmark {
  const UpdateBookmark(this._repository);

  final BookmarksRepository _repository;

  Future<Result<Bookmark>> call(String id, BookmarkInput input) =>
      _repository.update(id, input);
}
