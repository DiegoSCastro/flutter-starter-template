import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

typedef SignInParams = ({String username, String password});

@injectable
class SignIn extends UseCase<SignInParams, AuthUser> {
  const SignIn(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(SignInParams param) {
    return runResultGuarded(
      () => _repository.signIn(
        username: param.username,
        password: param.password,
      ),
    );
  }
}
