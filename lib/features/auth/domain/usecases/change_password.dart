import 'package:injectable/injectable.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

typedef ChangePasswordParams = ({String currentPassword, String newPassword});

@injectable
class ChangePassword extends UseCase<ChangePasswordParams, void> {
  const ChangePassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<void>> call(ChangePasswordParams param) {
    return runResultGuarded(
      () => _repository.changePassword(
        currentPassword: param.currentPassword,
        newPassword: param.newPassword,
      ),
    );
  }
}
