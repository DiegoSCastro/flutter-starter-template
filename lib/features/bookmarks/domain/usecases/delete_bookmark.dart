import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../repositories/bookmarks_repository.dart';

@injectable
class DeleteBookmark {
  const DeleteBookmark(this._repository);

  final BookmarksRepository _repository;

  Future<Result<void>> call(String id) => _repository.delete(id);
}
