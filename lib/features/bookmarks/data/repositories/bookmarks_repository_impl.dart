import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import '../local/bookmarks_local_data_source.dart';

@LazySingleton(as: BookmarksRepository)
class BookmarksRepositoryImpl implements BookmarksRepository {
  BookmarksRepositoryImpl(this._local);

  final BookmarksLocalDataSource _local;

  @override
  Future<Result<List<Bookmark>>> list() async {
    final rows = await _local.listAll();
    return Ok(rows.map((e) => e.toDomain()).toList(growable: false));
  }

  @override
  Future<Result<Bookmark>> get(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return const Err(NotFoundFailure('Bookmark not found.'));
    final entity = await _local.getById(intId);
    if (entity == null) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Bookmark>> create(BookmarkInput input) async {
    if (input.title.trim().isEmpty) {
      return const Err(ValidationFailure('Title is required.'));
    }
    if (input.url.trim().isEmpty) {
      return const Err(ValidationFailure('URL is required.'));
    }
    final entity = await _local.create(_normalize(input));
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<Bookmark>> update(String id, BookmarkInput input) async {
    final intId = int.tryParse(id);
    if (intId == null) return const Err(NotFoundFailure('Bookmark not found.'));
    if (input.title.trim().isEmpty) {
      return const Err(ValidationFailure('Title is required.'));
    }
    if (input.url.trim().isEmpty) {
      return const Err(ValidationFailure('URL is required.'));
    }
    final entity = await _local.update(intId, _normalize(input));
    if (entity == null) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    return Ok(entity.toDomain());
  }

  @override
  Future<Result<void>> delete(String id) async {
    final intId = int.tryParse(id);
    if (intId == null) return const Err(NotFoundFailure('Bookmark not found.'));
    final removed = await _local.delete(intId);
    if (!removed) {
      return const Err(NotFoundFailure('Bookmark not found.'));
    }
    return const Ok(null);
  }

  /// Trim + dedupe tags so storage matches what the server used to do.
  BookmarkInput _normalize(BookmarkInput input) {
    final seen = <String>{};
    final tags = <String>[];
    for (final raw in input.tags) {
      final t = raw.trim();
      if (t.isEmpty || !seen.add(t)) continue;
      tags.add(t);
    }
    return BookmarkInput(
      title: input.title.trim(),
      url: input.url.trim(),
      description: input.description.trim(),
      tags: tags,
    );
  }
}
