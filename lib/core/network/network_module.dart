import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/env_config.dart';

BaseOptions apiBaseOptions(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  contentType: 'application/json',
);

@module
abstract class NetworkModule {
  /// Plain Dio with no auth/refresh wiring. Used by callers that must bypass
  /// application-level interceptors.
  @lazySingleton
  @Named('plain')
  Dio providePlainDio(EnvConfig env) => Dio(apiBaseOptions(env.apiBaseUrl));
}
