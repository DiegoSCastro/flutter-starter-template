import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

typedef RegisterParams = ({String username, String password});

@injectable
class Register extends UseCase<RegisterParams, AuthUser> {
  const Register(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(RegisterParams param) {
    if (param.username.isEmpty || param.password.isEmpty) {
      return Future.value(
        const Err(
          InvalidCredentialsFailure('Username and password are required.'),
        ),
      );
    }
    return runResultGuarded(
      () => _repository.register(
        username: param.username,
        password: param.password,
      ),
    );
  }
}
