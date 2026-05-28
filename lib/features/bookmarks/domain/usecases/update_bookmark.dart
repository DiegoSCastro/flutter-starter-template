import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

typedef UpdateBookmarkParams = ({String id, BookmarkInput input});

@injectable
class UpdateBookmark extends UseCase<UpdateBookmarkParams, Bookmark> {
  const UpdateBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(UpdateBookmarkParams param) {
    return runResultGuarded(() => _repository.update(param.id, param.input));
  }
}
