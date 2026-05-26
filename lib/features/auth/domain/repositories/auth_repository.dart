import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  });

  Future<Result<void>> signOut();

  /// Loads any persisted session and attempts to refresh its access token.
  /// Returns `Ok(user)` if a valid session can be restored, otherwise `Err`.
  Future<Result<AuthUser>> restoreSession();

  AuthUser? get currentUser;
}
