import 'package:core_domain/core_domain.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notifications_feed.dart';
import '../../domain/entities/user_activity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_dto.dart';
import '../models/user_activity_dto.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDataSource _remote;

  @override
  Future<Result<NotificationsFeed>> getFeed() async {
    // Fetch both lists concurrently; the record `.wait` propagates the first
    // failure so the use case's guard can map it to a Failure.
    final (notificationDtos, activityDtos) = await (
      _remote.listNotifications(),
      _remote.listActivity(),
    ).wait;

    return Ok(
      NotificationsFeed(
        notifications: notificationDtos
            .map(_toNotification)
            .toList(growable: false),
        activities: activityDtos.map(_toActivity).toList(growable: false),
      ),
    );
  }

  @override
  Future<Result<void>> markRead(String id) async {
    await _remote.markRead(id);
    return const Ok(null);
  }

  AppNotification _toNotification(NotificationDto dto) => AppNotification(
    id: dto.id,
    title: dto.title,
    body: dto.body,
    type: _notificationType(dto.type),
    isRead: dto.isRead,
    createdAt: dto.createdAt,
  );

  UserActivity _toActivity(UserActivityDto dto) => UserActivity(
    id: dto.id,
    description: dto.description,
    type: _activityType(dto.type),
    createdAt: dto.createdAt,
  );

  NotificationType _notificationType(String raw) => switch (raw) {
    'social' => NotificationType.social,
    'reminder' => NotificationType.reminder,
    'promotion' => NotificationType.promotion,
    _ => NotificationType.system,
  };

  UserActivityType _activityType(String raw) => switch (raw) {
    'created' => UserActivityType.created,
    'updated' => UserActivityType.updated,
    'deleted' => UserActivityType.deleted,
    'signed_in' => UserActivityType.signedIn,
    _ => UserActivityType.other,
  };
}
