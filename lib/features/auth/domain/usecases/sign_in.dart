import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String username,
    required String password,
  }) {
    return _repository.signIn(username: username, password: password);
  }
}
