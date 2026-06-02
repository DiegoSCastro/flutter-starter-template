import 'package:core_domain/core_domain.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class SignOut extends NoParamUseCase<void> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.signOut);
  }
}
