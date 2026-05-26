// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BookmarkRequest _$BookmarkRequestFromJson(Map<String, dynamic> json) =>
    _BookmarkRequest(
      title: json['title'] as String,
      url: json['url'] as String,
      description: json['description'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$BookmarkRequestToJson(_BookmarkRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'description': instance.description,
      'tags': instance.tags,
    };
