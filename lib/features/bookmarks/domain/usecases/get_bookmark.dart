import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class GetBookmark extends UseCase<String, Bookmark> {
  const GetBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<Bookmark>> call(String param) {
    return runResultGuarded(() => _repository.get(param));
  }
}
