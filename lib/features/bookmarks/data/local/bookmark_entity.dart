import 'package:objectbox/objectbox.dart';

import '../../domain/entities/bookmark.dart';

/// Sync lifecycle for a local row. Stored as int via [SyncState.code] so
/// ObjectBox doesn't need a converter.
enum SyncState {
  synced(0),
  pendingCreate(1),
  pendingUpdate(2),
  pendingDelete(3)
  ;

  const SyncState(this.code);

  final int code;

  static SyncState fromCode(int code) {
    for (final s in SyncState.values) {
      if (s.code == code) return s;
    }
    return SyncState.synced;
  }

  bool get isPending => this != SyncState.synced;
}

/// ObjectBox row for a bookmark. Mutable by necessity — ObjectBox writes back
/// into instances during property loading, so this cannot be a Freezed/sealed
/// class.
@Entity()
class BookmarkEntity {
  BookmarkEntity({
    this.id = 0,
    required this.uuid,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.serverUpdatedAt,
    this.syncStateCode = 0,
    this.imageUrls = const [],
    this.videoUrl,
  });

  /// ObjectBox primary key. Internal — never exposed to the domain layer.
  /// 0 means "new"; ObjectBox assigns it on first `put`.
  @Id()
  int id;

  /// Stable string ID used by the domain layer and by the server. Generated
  /// client-side at create time so the row has a meaningful id before the
  /// first successful sync.
  @Unique()
  String uuid;

  String title;
  String url;
  String description;
  List<String> tags;
  List<String> imageUrls;
  String? videoUrl;

  /// Stored and read back as UTC. Domain layer handles any presentation-time
  /// conversion to local.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;

  /// Local mutation time — bumped on any local change. Compared against
  /// [serverUpdatedAt] on pull to implement last-write-wins.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime updatedAt;

  /// Server's view of `updatedAt` at the time of the last successful pull/push.
  /// `null` for rows that haven't been synced yet (pendingCreate).
  @Property(type: PropertyType.dateNanoUtc)
  DateTime? serverUpdatedAt;

  /// Stored form of [syncState]. Use the [syncState] getter/setter instead.
  int syncStateCode;

  @Transient()
  SyncState get syncState => SyncState.fromCode(syncStateCode);
  set syncState(SyncState value) => syncStateCode = value.code;

  Bookmark toDomain() => Bookmark(
    id: uuid,
    title: title,
    url: url,
    description: description,
    tags: List.unmodifiable(tags),
    imageUrls: List.unmodifiable(imageUrls),
    videoUrl: videoUrl,
    createdAt: createdAt,
    updatedAt: updatedAt,
    isPendingSync: syncState.isPending,
  );

  /// Mutates this entity from a [BookmarkInput] for create/update flows.
  /// Bumps `updatedAt`; leaves `createdAt` alone so updates preserve it.
  void applyInput(BookmarkInput input, {required DateTime now}) {
    title = input.title;
    url = input.url;
    description = input.description;
    tags = List.of(input.tags);
    imageUrls = List.of(input.imageUrls);
    videoUrl = input.videoUrl;
    updatedAt = now;
  }
}
