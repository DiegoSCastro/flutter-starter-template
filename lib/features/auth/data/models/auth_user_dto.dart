import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/auth_user.dart';

part 'auth_user_dto.freezed.dart';
part 'auth_user_dto.g.dart';

@Freezed(copyWith: false, equal: false)
abstract class AuthUserDto with _$AuthUserDto {

  const factory AuthUserDto({required String id, required String username}) =
      _AuthUserDto;
  const AuthUserDto._();

  factory AuthUserDto.fromJson(Map<String, dynamic> json) =>
      _$AuthUserDtoFromJson(json);

  AuthUser toDomain() => AuthUser(id: id, username: username);
}
