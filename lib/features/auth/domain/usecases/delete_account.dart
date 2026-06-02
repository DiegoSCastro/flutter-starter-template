import 'package:core_domain/core_domain.dart';
import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

@injectable
class DeleteAccount extends NoParamUseCase<void> {
  const DeleteAccount(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.deleteAccount);
  }
}
