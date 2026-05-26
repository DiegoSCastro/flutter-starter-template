import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_user_dto.g.dart';

@JsonSerializable()
class AuthUserDto {
  const AuthUserDto({required this.id, required this.username});

  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);

  final String id;
  final String username;

  Map<String, dynamic> toJson() => _$AuthUserDtoToJson(this);

  AuthUser toDomain() => AuthUser(id: id, username: username);
}
