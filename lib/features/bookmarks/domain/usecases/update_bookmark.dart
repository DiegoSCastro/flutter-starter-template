import 'package:injectable/injectable.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/use_case.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';
import '_bookmark_validation.dart';

typedef UpdateBookmarkParams = ({String id, BookmarkInput input});

@injectable
class UpdateBookmark extends UseCase<UpdateBookmarkParams, Bookmark> {
  const UpdateBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(UpdateBookmarkParams param) {
    final failure = validateBookmarkInput(param.input);
    if (failure != null) return Future.value(Err(failure));
    return runResultGuarded(() => _repository.update(param.id, param.input));
  }
}
