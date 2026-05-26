import 'package:objectbox/objectbox.dart';

import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmarks_repository.dart';

/// ObjectBox row for a bookmark. Mutable by necessity — ObjectBox writes back
/// into instances during property loading, so this cannot be a Freezed/sealed
/// class.
@Entity()
class BookmarkEntity {
  BookmarkEntity({
    this.id = 0,
    required this.title,
    required this.url,
    required this.description,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ObjectBox primary key. 0 means "new" — ObjectBox assigns the value on
  /// first `put`. The String id exposed to the domain layer is this value
  /// stringified, set lazily via [Bookmark.id].
  @Id()
  int id;

  String title;
  String url;
  String description;
  List<String> tags;

  /// Stored and read back as UTC millis. Domain layer handles any
  /// presentation-time conversion to local.
  @Property(type: PropertyType.dateNanoUtc)
  DateTime createdAt;
  @Property(type: PropertyType.dateNanoUtc)
  DateTime updatedAt;

  Bookmark toDomain() => Bookmark(
        id: id.toString(),
        title: title,
        url: url,
        description: description,
        tags: List.unmodifiable(tags),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// Mutates this entity from a [BookmarkInput] for create/update flows.
  /// Bumps `updatedAt`; leaves `createdAt` alone so updates preserve it.
  void applyInput(BookmarkInput input, {required DateTime now}) {
    title = input.title;
    url = input.url;
    description = input.description;
    tags = List.of(input.tags);
    updatedAt = now;
  }

  factory BookmarkEntity.fromInput(BookmarkInput input, {required DateTime now}) =>
      BookmarkEntity(
        title: input.title,
        url: input.url,
        description: input.description,
        tags: List.of(input.tags),
        createdAt: now,
        updatedAt: now,
      );
}
