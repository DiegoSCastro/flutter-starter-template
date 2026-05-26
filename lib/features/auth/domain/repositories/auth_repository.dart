import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  });

  Future<Result<void>> signOut();

  AuthUser? get currentUser;
}
