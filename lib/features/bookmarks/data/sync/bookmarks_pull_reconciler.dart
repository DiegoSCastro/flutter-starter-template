import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmark_entity.dart';
import '../local/bookmarks_local_data_source.dart';

/// Reconciles the local bookmark store with the server's latest list.
class BookmarksPullReconciler {
  BookmarksPullReconciler(this._local, this._remote);

  final BookmarksLocalDataSource _local;
  final BookmarksRemoteDataSource _remote;

  Future<void> pull() async {
    final serverList = await _remote.list();
    final serverByUuid = {for (final dto in serverList) dto.id: dto};
    final localByUuid = <String, BookmarkEntity>{
      for (final row in await _local.listAll()) row.uuid: row,
    };

    for (final dto in serverList) {
      final local = localByUuid[dto.id];
      if (local == null) {
        await _local.put(
          BookmarkEntity(
            uuid: dto.id,
            title: dto.title,
            url: dto.url,
            description: dto.description,
            tags: List.of(dto.tags),
            imageUrls: List.of(dto.imageUrls),
            videoUrl: dto.videoUrl,
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt,
            serverUpdatedAt: dto.updatedAt,
            syncStateCode: SyncState.synced.code,
          ),
        );
        continue;
      }

      if (local.syncState.isPending) continue;
      if (dto.updatedAt.isAfter(local.updatedAt)) {
        local
          ..title = dto.title
          ..url = dto.url
          ..description = dto.description
          ..tags = List.of(dto.tags)
          ..imageUrls = List.of(dto.imageUrls)
          ..videoUrl = dto.videoUrl
          ..updatedAt = dto.updatedAt
          ..serverUpdatedAt = dto.updatedAt;
        await _local.put(local);
      }
    }

    for (final local in localByUuid.values) {
      if (local.syncState != SyncState.synced) continue;
      if (serverByUuid.containsKey(local.uuid)) continue;
      await _local.hardDelete(local.id);
    }
  }
}
