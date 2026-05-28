// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkRequest _$BookmarkRequestFromJson(Map<String, dynamic> json) =>
    _BookmarkRequest(
      id: json['id'] as String?,
      title: json['title'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$BookmarkRequestToJson(_BookmarkRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'description': instance.description,
      'tags': instance.tags,
      'imageUrls': instance.imageUrls,
    };
