import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

/// Reads bookmarks from the local store without triggering a sync.
///
/// Used to refresh the list after a sync cycle completes, avoiding the
/// read-triggers-sync feedback loop that `ListBookmarks` would cause.
@injectable
class ListLocalBookmarks extends NoParamUseCase<List<Bookmark>> {
  const ListLocalBookmarks(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<List<Bookmark>>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.listLocal);
  }
}
