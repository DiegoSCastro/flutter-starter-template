import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../datasources/auth_local_data_source.dart';
import '../models/refresh_token_response.dart';

/// Single-flight refresh: concurrent callers share one in-flight POST so the
/// server doesn't see a stampede of refresh requests during a 401 storm.
@lazySingleton
class TokenRefresher {
  TokenRefresher(this._local, @Named('plain') this._dio);

  final AuthLocalDataSource _local;
  final Dio _dio;
  Future<bool>? _inflight;

  /// Attempt to exchange the persisted refresh token for a new access/refresh
  /// pair. Returns `true` on success (storage is updated) or `false` on any
  /// failure (storage is cleared so the UI can route to sign-in).
  Future<bool> refresh() {
    return _inflight ??= _run()..whenComplete(() => _inflight = null);
  }

  Future<bool> _run() async {
    final token = _local.refreshToken;
    if (token == null) return false;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': token},
      );
      final body = response.data;
      if (body == null) {
        await _local.clearSession();
        return false;
      }
      final parsed = RefreshTokenResponse.fromJson(body);
      await _local.updateTokens(
        accessToken: parsed.accessToken,
        refreshToken: parsed.refreshToken,
      );
      return true;
    } on DioException {
      await _local.clearSession();
      return false;
    }
  }
}
