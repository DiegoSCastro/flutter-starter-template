import 'package:injectable/injectable.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/use_case.dart';
import '../../../../shared/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RestoreSession extends NoParamUseCase<AuthUser> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthUser>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.restoreSession);
  }
}
