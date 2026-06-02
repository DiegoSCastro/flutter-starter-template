import 'package:core_domain/core_domain.dart';
import 'package:flutter_starter_template/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:flutter_starter_template/features/notifications/data/models/notification_dto.dart';
import 'package:flutter_starter_template/features/notifications/data/models/user_activity_dto.dart';
import 'package:flutter_starter_template/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/user_activity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRemoteDataSource extends Mock
    implements NotificationsRemoteDataSource {}

void main() {
  late MockNotificationsRemoteDataSource remote;
  late NotificationsRepositoryImpl repository;

  final now = DateTime(2026, 6, 1, 12);

  setUp(() {
    remote = MockNotificationsRemoteDataSource();
    repository = NotificationsRepositoryImpl(remote);
  });

  group('NotificationsRepositoryImpl', () {
    test('getFeed maps remote DTOs to domain entities', () async {
      when(() => remote.listNotifications()).thenAnswer(
        (_) async => [
          NotificationDto(
            id: 'n-1',
            title: 'Mention',
            body: 'Alice mentioned you',
            type: 'social',
            createdAt: now,
          ),
          NotificationDto(
            id: 'n-2',
            title: 'Reminder',
            body: 'Review saved links',
            type: 'reminder',
            isRead: true,
            createdAt: now.add(const Duration(minutes: 1)),
          ),
          NotificationDto(
            id: 'n-3',
            title: 'Promo',
            body: 'Try premium',
            type: 'promotion',
            createdAt: now.add(const Duration(minutes: 2)),
          ),
          NotificationDto(
            id: 'n-4',
            title: 'Fallback',
            body: 'Unknown type',
            type: 'unexpected',
            createdAt: now.add(const Duration(minutes: 3)),
          ),
        ],
      );
      when(() => remote.listActivity()).thenAnswer(
        (_) async => [
          UserActivityDto(
            id: 'a-1',
            description: 'Created bookmark',
            type: 'created',
            createdAt: now,
          ),
          UserActivityDto(
            id: 'a-2',
            description: 'Signed in',
            type: 'signed_in',
            createdAt: now.add(const Duration(minutes: 1)),
          ),
          UserActivityDto(
            id: 'a-3',
            description: 'Fallback',
            type: 'unexpected',
            createdAt: now.add(const Duration(minutes: 2)),
          ),
        ],
      );

      final result = await repository.getFeed();

      final ok = result as Ok<NotificationsFeed>;
      expect(ok.value.notifications, hasLength(4));
      expect(ok.value.notifications[0].type, NotificationType.social);
      expect(ok.value.notifications[1].type, NotificationType.reminder);
      expect(ok.value.notifications[1].isRead, isTrue);
      expect(ok.value.notifications[2].type, NotificationType.promotion);
      expect(ok.value.notifications[3].type, NotificationType.system);
      expect(ok.value.activities, hasLength(3));
      expect(ok.value.activities[0].type, UserActivityType.created);
      expect(ok.value.activities[1].type, UserActivityType.signedIn);
      expect(ok.value.activities[2].type, UserActivityType.other);
      verify(() => remote.listNotifications()).called(1);
      verify(() => remote.listActivity()).called(1);
    });

    test('markRead delegates to the remote data source', () async {
      when(() => remote.markRead('n-1')).thenAnswer((_) async {});

      final result = await repository.markRead('n-1');

      expect(result, isA<Ok<void>>());
      verify(() => remote.markRead('n-1')).called(1);
    });
  });
}
