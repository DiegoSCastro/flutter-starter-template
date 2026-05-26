import 'package:json_annotation/json_annotation.dart';

import 'auth_user_dto.dart';

part 'sign_in_response.g.dart';

@JsonSerializable(createToJson: false)
class SignInResponse {
  const SignInResponse({required this.user, required this.token});

  factory SignInResponse.fromJson(Map<String, dynamic> json) =>
      _$SignInResponseFromJson(json);

  final AuthUserDto user;
  final String token;
}
