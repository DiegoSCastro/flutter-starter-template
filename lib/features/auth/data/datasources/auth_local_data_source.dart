import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_user.dart';

/// Source of truth for the fake authentication session. Persists only in
/// memory — replace with a secure storage backed implementation later.
abstract interface class AuthLocalDataSource {
  AuthUser? get currentUser;
  void setCurrentUser(AuthUser? user);
}

@LazySingleton(as: AuthLocalDataSource)
class InMemoryAuthDataSource implements AuthLocalDataSource {
  AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  void setCurrentUser(AuthUser? user) {
    _user = user;
  }
}
