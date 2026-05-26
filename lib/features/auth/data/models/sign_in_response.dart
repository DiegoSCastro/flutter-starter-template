import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_user_dto.dart';

part 'sign_in_response.freezed.dart';
part 'sign_in_response.g.dart';

@freezed
abstract class SignInResponse with _$SignInResponse {
  const factory SignInResponse({
    required AuthUserDto user,
    required String token,
  }) = _SignInResponse;

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);
}
