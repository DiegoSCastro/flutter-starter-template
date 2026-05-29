import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
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
