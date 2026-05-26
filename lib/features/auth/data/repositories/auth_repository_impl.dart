import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource);

  final AuthLocalDataSource _dataSource;

  @override
  AuthUser? get currentUser => _dataSource.currentUser;

  @override
  Future<Result<AuthUser>> signIn({
    required String username,
    required String password,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      return const Err(InvalidCredentialsFailure(
        'Username and password are required.',
      ));
    }
    final user = AuthUser(id: 'fake-${username.hashCode}', username: username);
    _dataSource.setCurrentUser(user);
    return Ok(user);
  }

  @override
  Future<Result<void>> signOut() async {
    _dataSource.setCurrentUser(null);
    return const Ok(null);
  }
}
