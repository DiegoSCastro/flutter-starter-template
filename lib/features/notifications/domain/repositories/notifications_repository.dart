import '../../../../core/domain/result.dart';
import '../entities/notifications_feed.dart';

abstract interface class NotificationsRepository {
  /// Loads the user's notifications and recent activity in one shot.
  Future<Result<NotificationsFeed>> getFeed();

  /// Marks the notification with [id] as read on the server.
  Future<Result<void>> markRead(String id);
}
