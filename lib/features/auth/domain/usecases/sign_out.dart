import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.signOut();
}
