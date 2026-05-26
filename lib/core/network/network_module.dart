import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/bookmarks/data/datasources/bookmarks_remote_data_source.dart';
import 'auth_interceptor.dart';
import 'token_refresher.dart';

/// Base URL of the local `simple_backend_server` instance.
const String _kBaseUrl = 'http://localhost:8080';

BaseOptions _baseOptions() => BaseOptions(
      baseUrl: _kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );

@module
abstract class NetworkModule {
  /// Plain Dio with no auth/refresh wiring. Used by [TokenRefresher] so the
  /// refresh call itself can never recurse through the 401-retry interceptor.
  @lazySingleton
  @Named('plain')
  Dio providePlainDio() => Dio(_baseOptions());

  /// Authenticated Dio used by the rest of the app: attaches the Bearer token
  /// and, on 401, transparently refreshes once and retries the request.
  @lazySingleton
  Dio provideDio(AuthLocalDataSource session, TokenRefresher refresher) {
    final dio = Dio(_baseOptions());
    dio.interceptors.add(AuthInterceptor(session, refresher, dio));
    return dio;
  }

  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);

  @lazySingleton
  BookmarksRemoteDataSource provideBookmarksRemoteDataSource(Dio dio) =>
      BookmarksRemoteDataSource(dio);
}
