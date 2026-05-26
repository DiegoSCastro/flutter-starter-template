import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';

/// Base URL of the local `simple_backend_server` instance.
const String _kBaseUrl = 'http://localhost:8080';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio provideDio(AuthLocalDataSource session) {
    final dio = Dio(
      BaseOptions(
        baseUrl: _kBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = session.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  @lazySingleton
  AuthRemoteDataSource provideAuthRemoteDataSource(Dio dio) =>
      AuthRemoteDataSource(dio);
}
