import 'package:core_domain/core_domain.dart';
import 'package:injectable/injectable.dart';

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
