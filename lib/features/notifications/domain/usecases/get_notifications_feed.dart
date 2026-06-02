import 'package:injectable/injectable.dart';

import '../../../../core/domain/result.dart';
import '../../../../core/domain/use_case.dart';
import '../entities/notifications_feed.dart';
import '../repositories/notifications_repository.dart';

@injectable
class GetNotificationsFeed extends NoParamUseCase<NotificationsFeed> {
  const GetNotificationsFeed(this._repository);

  final NotificationsRepository _repository;

  @override
  Future<Result<NotificationsFeed>> call([NoParams param = noParams]) {
    return runResultGuarded(_repository.getFeed);
  }
}
