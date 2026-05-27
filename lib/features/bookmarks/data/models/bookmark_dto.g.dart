// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkDto _$BookmarkDtoFromJson(Map<String, dynamic> json) => _BookmarkDto(
  id: json['id'] as String,
  title: json['title'] as String,
  url: json['url'] as String,
  description: json['description'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BookmarkDtoToJson(_BookmarkDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'description': instance.description,
      'tags': instance.tags,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
