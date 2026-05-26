import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/bookmark.dart';

part 'bookmark_dto.freezed.dart';
part 'bookmark_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class BookmarkDto with _$BookmarkDto {
  const BookmarkDto._();

  const factory BookmarkDto({
    required String id,
    required String title,
    required String url,
    required String description,
    required List<String> tags,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _BookmarkDto;

  factory BookmarkDto.fromJson(Map<String, dynamic> json) =>
      _$BookmarkDtoFromJson(json);

  Bookmark toDomain() => Bookmark(
        id: id,
        title: title,
        url: url,
        description: description,
        tags: List.unmodifiable(tags),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
