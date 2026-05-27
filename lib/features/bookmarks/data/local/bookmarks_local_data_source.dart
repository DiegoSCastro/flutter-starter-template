import 'package:injectable/injectable.dart' hide Order;

import '../../../../objectbox.g.dart' hide SyncState;
import 'bookmark_entity.dart';

/// ObjectBox-backed CRUD + sync helpers. All operations are synchronous on
/// the ObjectBox side; wrapped in `Future` to keep the repository contract
/// async-friendly.
///
/// Identity at this layer is the string [BookmarkEntity.uuid]. The integer
/// `id` is an internal ObjectBox PK that callers never see.
abstract interface class BookmarksLocalDataSource {
  /// All non-tombstoned bookmarks, newest-first.
  Future<List<BookmarkEntity>> listVisible();

  /// Includes tombstoned (pendingDelete) rows. Used by the sync service.
  Future<List<BookmarkEntity>> listAll();

  Future<BookmarkEntity?> getByUuid(String uuid);

  /// Rows with any non-synced state, ordered by [BookmarkEntity.updatedAt].
  Future<List<BookmarkEntity>> listPending();

  /// Inserts a new row in [SyncState.pendingCreate].
  Future<BookmarkEntity> putNew(BookmarkEntity entity);

  /// Persists changes to an existing row. Caller owns sync state changes.
  Future<void> put(BookmarkEntity entity);

  /// Hard-removes by internal PK. Used after a successful pendingDelete push.
  Future<void> hardDelete(int pk);
}

@LazySingleton(as: BookmarksLocalDataSource)
class ObjectBoxBookmarksDataSource implements BookmarksLocalDataSource {
  ObjectBoxBookmarksDataSource(Store store) : _box = store.box<BookmarkEntity>();

  final Box<BookmarkEntity> _box;

  @override
  Future<List<BookmarkEntity>> listVisible() async {
    final query = _box
        .query(BookmarkEntity_.syncStateCode
            .notEquals(SyncState.pendingDelete.code))
        .order(BookmarkEntity_.createdAt, flags: Order.descending)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

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
  Future<BookmarkEntity?> getByUuid(String uuid) async {
    final query = _box.query(BookmarkEntity_.uuid.equals(uuid)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }

  @override
  Future<List<BookmarkEntity>> listPending() async {
    final query = _box
        .query(BookmarkEntity_.syncStateCode.notEquals(SyncState.synced.code))
        .order(BookmarkEntity_.updatedAt)
        .build();
    try {
      return query.find();
    } finally {
      query.close();
    }
  }

  @override
  Future<BookmarkEntity> putNew(BookmarkEntity entity) async {
    _box.put(entity);
    return entity;
  }

  @override
  Future<void> put(BookmarkEntity entity) async {
    _box.put(entity);
  }

  @override
  Future<void> hardDelete(int pk) async {
    _box.remove(pk);
  }
}
