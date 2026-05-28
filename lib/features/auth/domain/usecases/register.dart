import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

typedef RegisterParams = ({String username, String password});

@injectable
class Register extends UseCase<RegisterParams, AuthUser> {
  const Register(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call(RegisterParams param) {
    return runResultGuarded(
      () => _repository.register(
        username: param.username,
        password: param.password,
      ),
    );
  }
}
