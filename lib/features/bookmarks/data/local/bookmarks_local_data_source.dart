import 'package:injectable/injectable.dart' hide Order;
import 'package:objectbox/objectbox.dart';

import '../../../../objectbox.g.dart';
import '../../domain/repositories/bookmarks_repository.dart';
import 'bookmark_entity.dart';

/// ObjectBox-backed CRUD for bookmarks. All operations are synchronous on
/// the ObjectBox side; wrapped in `Future` to match the repository contract
/// and to leave room for async backends later.
abstract interface class BookmarksLocalDataSource {
  Future<List<BookmarkEntity>> listAll();
  Future<BookmarkEntity?> getById(int id);
  Future<BookmarkEntity> create(BookmarkInput input);
  Future<BookmarkEntity?> update(int id, BookmarkInput input);
  Future<bool> delete(int id);
}

@LazySingleton(as: BookmarksLocalDataSource)
class ObjectBoxBookmarksDataSource implements BookmarksLocalDataSource {
  ObjectBoxBookmarksDataSource(Store store) : _box = store.box<BookmarkEntity>();

  final Box<BookmarkEntity> _box;

  @override
  Future<List<BookmarkEntity>> listAll() async {
    final query = _box
        .query()
        .order(BookmarkEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<BookmarkEntity?> getById(int id) async => _box.get(id);

  @override
  Future<BookmarkEntity> create(BookmarkInput input) async {
    final entity = BookmarkEntity.fromInput(input, now: DateTime.now().toUtc());
    _box.put(entity);
    return entity;
  }

  @override
  Future<BookmarkEntity?> update(int id, BookmarkInput input) async {
    final existing = _box.get(id);
    if (existing == null) return null;
    existing.applyInput(input, now: DateTime.now().toUtc());
    _box.put(existing);
    return existing;
  }

  @override
  Future<bool> delete(int id) async => _box.remove(id);
}
