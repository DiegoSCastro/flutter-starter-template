import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_user.dart';

/// Persists the active authentication session — current user, access token,
/// and refresh token — in platform-encrypted storage (Keychain on iOS,
/// EncryptedSharedPreferences/Keystore on Android).
///
/// All getters cache in memory after the first read so the Dio interceptor's
/// hot path doesn't hit native channels per request. `load` must be awaited
/// once during app bootstrap before any token-bearing request is made.
abstract interface class AuthLocalDataSource {
  AuthUser? get currentUser;
  String? get accessToken;
  String? get refreshToken;

  Future<void> load();
  Future<void> setSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  });
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearSession();
}

const _kUserKey = 'auth.user';
const _kAccessKey = 'auth.access_token';
const _kRefreshKey = 'auth.refresh_token';

@LazySingleton(as: AuthLocalDataSource)
class SecureStorageAuthDataSource implements AuthLocalDataSource {
  SecureStorageAuthDataSource(this._storage);

  final FlutterSecureStorage _storage;

  AuthUser? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _loaded = false;

  @override
  AuthUser? get currentUser => _user;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<void> load() async {
    if (_loaded) return;
    final values = await _storage.readAll();
    _accessToken = values[_kAccessKey];
    _refreshToken = values[_kRefreshKey];
    final userJson = values[_kUserKey];
    if (userJson != null) {
      final map = jsonDecode(userJson) as Map<String, dynamic>;
      _user = AuthUser(
        id: map['id'] as String,
        username: map['username'] as String,
      );
    }
    _loaded = true;
  }

  @override
  Future<void> setSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    _user = user;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _loaded = true;
    await Future.wait([
      _storage.write(
        key: _kUserKey,
        value: jsonEncode({'id': user.id, 'username': user.username}),
      ),
      _storage.write(key: _kAccessKey, value: accessToken),
      _storage.write(key: _kRefreshKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _kAccessKey, value: accessToken),
      _storage.write(key: _kRefreshKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clearSession() async {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    await Future.wait([
      _storage.delete(key: _kUserKey),
      _storage.delete(key: _kAccessKey),
      _storage.delete(key: _kRefreshKey),
    ]);
  }
}

@module
abstract class SecureStorageModule {
  @lazySingleton
  FlutterSecureStorage provideSecureStorage() => const FlutterSecureStorage();
}
