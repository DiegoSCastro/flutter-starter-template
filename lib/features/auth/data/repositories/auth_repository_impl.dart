import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/sign_in_request.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  AuthUser? get currentUser => _local.currentUser;

  @override
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      return const Err(
        InvalidCredentialsFailure('Username and password are required.'),
      );
    }
    try {
      final response = await _remote.signIn(
        SignInRequest(username: username, password: password),
      );
      final user = response.user.toDomain();
      _local.setSession(user: user, token: response.token);
      return Ok(user);
    } on DioException catch (e) {
      return Err(_mapDioError(e));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remote.signOut();
    } on DioException {
      // Best-effort: drop the local session even if the server call fails so
      // the user isn't stuck signed in after a network blip.
    }
    _local.clearSession();
    return const Ok(null);
  }

  Failure _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) {
      final message = _extractMessage(e.response?.data) ??
          'Invalid username or password.';
      return InvalidCredentialsFailure(message);
    }
    return UnknownFailure(e.message ?? 'Network error');
  }

  String? _extractMessage(Object? body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String) return message;
    }
    return null;
  }
}
