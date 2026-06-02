import 'package:injectable/injectable.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/use_case.dart';
import '../repositories/notifications_repository.dart';

@injectable
class MarkNotificationRead extends UseCase<String, void> {
  const MarkNotificationRead(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<void>> call(String id) {
    return runResultGuarded(() => _repository.markRead(id));
  }
}
