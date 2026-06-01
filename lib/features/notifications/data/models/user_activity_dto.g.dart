// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_activity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserActivityDto _$UserActivityDtoFromJson(Map<String, dynamic> json) =>
    _UserActivityDto(
      id: json['id'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserActivityDtoToJson(_UserActivityDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
    };
