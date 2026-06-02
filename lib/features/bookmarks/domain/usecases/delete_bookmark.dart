import 'package:injectable/injectable.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/use_case.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class DeleteBookmark extends UseCase<String, void> {
  const DeleteBookmark(this._repository);

  final BookmarksRepository _repository;

  @override
  Future<Result<void>> call(String param) {
    return runResultGuarded(() => _repository.delete(param));
  }
}
