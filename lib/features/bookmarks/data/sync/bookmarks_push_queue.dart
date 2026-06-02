import 'package:core_network/core_network.dart';

import '../datasources/bookmarks_remote_data_source.dart';
import '../local/bookmark_entity.dart';
import '../local/bookmarks_local_data_source.dart';
import '../models/bookmark_dto.dart';
import '../models/bookmark_request.dart';
import 'bookmark_media_upload_sync.dart';

/// Pushes pending local bookmark mutations to the remote API.
class BookmarksPushQueue {
  BookmarksPushQueue(
    this._local,
    this._remote, {
    BookmarkMediaUploadSync? mediaUploadSync,
  }) : _mediaUploadSync =
           mediaUploadSync ?? BookmarkMediaUploadSync(_local, _remote);

  final BookmarksLocalDataSource _local;
  final BookmarksRemoteDataSource _remote;
  final BookmarkMediaUploadSync _mediaUploadSync;

  /// Drains every pending row. Each row is isolated so a single permanently
  /// rejected row cannot block the rest of the queue. Returns true if any row
  /// failed and stayed pending.
  Future<bool> push() async {
    final pending = await _local.listPending();
    var hadFailure = false;
    for (final row in pending) {
      try {
        await _pushRow(row);
      } on Object {
        hadFailure = true;
      }
    }
    return hadFailure;
  }

  Future<void> _pushRow(BookmarkEntity row) async {
    switch (row.syncState) {
      case SyncState.pendingCreate:
        await _mediaUploadSync.checkpointUploads(row);
        try {
          final dto = await _remote.create(
            BookmarkRequest(
              id: row.uuid,
              title: row.title,
              url: row.url,
              description: row.description,
              tags: row.tags,
              imageUrls: row.imageUrls,
              videoUrl: row.videoUrl,
            ),
          );
          _markSynced(row, dto);
          await _local.put(row);
        } on DioException catch (e) {
          // 409: a previous attempt already created this row server-side, but
          // its response was lost. Pull reconciliation refreshes its fields.
          if (e.response?.statusCode != 409) rethrow;
          row.syncState = SyncState.synced;
          await _local.put(row);
        }
      case SyncState.pendingUpdate:
        await _mediaUploadSync.checkpointUploads(row);
        final dto = await _remote.update(
          row.uuid,
          BookmarkRequest(
            title: row.title,
            url: row.url,
            description: row.description,
            tags: row.tags,
            imageUrls: row.imageUrls,
            videoUrl: row.videoUrl,
          ),
        );
        _markSynced(row, dto);
        await _local.put(row);
      case SyncState.pendingDelete:
        try {
          await _remote.delete(row.uuid);
        } on DioException catch (e) {
          // 404 is fine: server already lost it. Anything else leaves the row
          // pending for the next sync.
          if (e.response?.statusCode != 404) rethrow;
        }
        await _local.hardDelete(row.id);
      case SyncState.synced:
        break;
    }
  }

  void _markSynced(BookmarkEntity row, BookmarkDto dto) {
    row
      ..syncState = SyncState.synced
      ..serverUpdatedAt = dto.updatedAt
      ..imageUrls = List.of(dto.imageUrls)
      ..videoUrl = dto.videoUrl;
  }
}
