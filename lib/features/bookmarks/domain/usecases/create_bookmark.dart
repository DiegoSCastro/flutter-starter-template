import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';
import '_bookmark_validation.dart';

@injectable
class CreateBookmark extends UseCase<BookmarkInput, Bookmark> {
  const CreateBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(BookmarkInput param) {
    final failure = validateBookmarkInput(param);
    if (failure != null) return Future.value(Err(failure));
    return runResultGuarded(() => _repository.create(param));
  }
}
