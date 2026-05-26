import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_user.dart';

/// In-memory cache for the active authentication session: the current user
/// and the bearer token used by the API client interceptor. Swap for a
/// secure-storage-backed implementation when persistence is needed.
abstract interface class AuthLocalDataSource {
  AuthUser? get currentUser;
  String? get accessToken;
  void setSession({required AuthUser user, required String token});
  void clearSession();
}

@LazySingleton(as: AuthLocalDataSource)
class InMemoryAuthDataSource implements AuthLocalDataSource {
  AuthUser? _user;
  String? _token;

  @override
  AuthUser? get currentUser => _user;

  @override
  String? get accessToken => _token;

  @override
  void setSession({required AuthUser user, required String token}) {
    _user = user;
    _token = token;
  }

  @override
  void clearSession() {
    _user = null;
    _token = null;
  }
}
