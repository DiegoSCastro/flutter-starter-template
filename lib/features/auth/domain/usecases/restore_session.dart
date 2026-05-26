import 'package:injectable/injectable.dart';

import '../../../../core/utils/result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RestoreSession {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call() => _repository.restoreSession();
}
