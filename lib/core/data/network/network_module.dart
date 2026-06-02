import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../config/env_config.dart';

BaseOptions apiBaseOptions(
  String baseUrl, {
  Duration timeout = const Duration(seconds: 10),
}) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: timeout,
  receiveTimeout: timeout,
  contentType: 'application/json',
);

/// Verbose request/response logging for development builds only. Routes Dio's
/// output through `dart:developer` (not `print`) so it integrates with
/// DevTools and stays off the release console. Gate the call site on
/// [EnvConfig.isDev].
Interceptor devLogInterceptor() => LogInterceptor(
  requestBody: true,
  responseBody: true,
  logPrint: (object) => developer.log(object.toString(), name: 'dio'),
);

@module
abstract class NetworkModule {
  /// Plain Dio with no auth/refresh wiring. Used by callers that must bypass
  /// application-level interceptors.
  @lazySingleton
  @Named('plain')
  Dio providePlainDio(EnvConfig env) =>
      Dio(apiBaseOptions(env.apiBaseUrl, timeout: env.apiTimeout));
}
