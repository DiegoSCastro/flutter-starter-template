import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../config/env_config.dart';

const _apiTimeout = Duration(seconds: 10);

BaseOptions apiBaseOptions(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: _apiTimeout,
  receiveTimeout: _apiTimeout,
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
