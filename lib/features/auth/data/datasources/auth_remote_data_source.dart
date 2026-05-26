import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/sign_in_request.dart';
import '../models/sign_in_response.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) =
      _AuthRemoteDataSource;

  @POST('/api/auth/sign-in')
  Future<SignInResponse> signIn(@Body() SignInRequest body);

  @POST('/api/auth/sign-out')
  Future<void> signOut();
}
