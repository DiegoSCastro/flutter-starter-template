import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/network/network_module.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import 'auth_interceptor.dart';
import 'token_refresher.dart';

@module
abstract class AuthNetworkModule {
  /// Authenticated Dio used by the app: attaches the Bearer token and, on 401,
  /// transparently refreshes once and retries the request.
  @lazySingleton
  Dio provideDio(
    AuthLocalDataSource session,
    TokenRefresher refresher,
    EnvConfig env,
  ) {
    final dio = Dio(apiBaseOptions(env.apiBaseUrl));
    dio.interceptors.add(AuthInterceptor(session, refresher, dio));
    return dio;
  }

  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);
}
