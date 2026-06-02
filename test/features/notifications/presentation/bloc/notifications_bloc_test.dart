import 'package:architecture/architecture.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/user_activity.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/get_notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:flutter_starter_template/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/test_utils.dart';

import '../../../../test_utils.dart';

class MockGetNotificationsFeed extends Mock implements GetNotificationsFeed {}

class MockMarkNotificationRead extends Mock implements MarkNotificationRead {}

void main() {
  late MockGetNotificationsFeed getFeed;
  late MockMarkNotificationRead markRead;

  final now = DateTime(2026, 6, 1, 12);
  late AppNotification unreadNotification;
  late AppNotification readNotification;
  late UserActivity activity;
  late NotificationsFeed feed;

  late MockActivityNotifier activityNotifier;

  setUp(() {
    getFeed = MockGetNotificationsFeed();
    markRead = MockMarkNotificationRead();
    activityNotifier = MockActivityNotifier();
    when(() => activityNotifier.onActivityOccurred)
        .thenAnswer((_) => const Stream.empty());

    unreadNotification = AppNotification(
      id: 'n-1',
      title: 'Mention',
      body: 'Alice mentioned you',
      type: NotificationType.social,
      isRead: false,
      createdAt: now,
    );
    readNotification = AppNotification(
      id: 'n-2',
      title: 'System',
      body: 'Already handled',
      type: NotificationType.system,
      isRead: true,
      createdAt: now.add(const Duration(minutes: 1)),
    );
    activity = UserActivity(
      id: 'a-1',
      description: 'Created bookmark',
      type: UserActivityType.created,
      createdAt: now,
    );
    feed = NotificationsFeed(
      notifications: [unreadNotification, readNotification],
      activities: [activity],
    );
  });

  NotificationsBloc buildBloc() => NotificationsBloc(getFeed, markRead, activityNotifier);

  group('NotificationsBloc', () {
    test('initial state is empty', () {
      final bloc = buildBloc();
      expect(bloc.state.notifications, isEmpty);
      expect(bloc.state.activities, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.unreadCount, 0);
      bloc.close();
    });

    blocTest<NotificationsBloc, NotificationsState>(
      'emits loading then feed on load success',
      setUp: () {
        when(() => getFeed()).thenAnswer((_) async => Ok(feed));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const NotificationsLoadRequested()),
      expect: () => [
        predicate<NotificationsState>(
          (state) => state.isLoading && state.failure == null,
        ),
        predicate<NotificationsState>(
          (state) =>
              !state.isLoading &&
              state.notifications.length == 2 &&
              state.activities.length == 1 &&
              state.unreadCount == 1,
        ),
      ],
      verify: (_) {
        verify(() => getFeed()).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'emits loading then failure on load error',
      setUp: () {
        when(
          () => getFeed(),
        ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const NotificationsLoadRequested()),
      expect: () => [
        predicate<NotificationsState>((state) => state.isLoading),
        predicate<NotificationsState>(
          (state) => !state.isLoading && state.failure is UnknownFailure,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'optimistically marks a notification as read',
      setUp: () {
        when(() => markRead('n-1')).thenAnswer((_) async => const Ok(null));
      },
      build: buildBloc,
      seed: () => NotificationsState(
        notifications: [unreadNotification, readNotification],
      ),
      act: (bloc) => bloc.add(const NotificationMarkReadRequested('n-1')),
      expect: () => [
        predicate<NotificationsState>(
          (state) =>
              state.notifications.first.isRead &&
              state.notifications.last.isRead &&
              state.unreadCount == 0,
        ),
      ],
      verify: (_) {
        verify(() => markRead('n-1')).called(1);
      },
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'rolls back optimistic read state when marking read fails',
      setUp: () {
        when(
          () => markRead('n-1'),
        ).thenAnswer((_) async => const Err(UnknownFailure('Failed')));
      },
      build: buildBloc,
      seed: () => NotificationsState(
        notifications: [unreadNotification, readNotification],
      ),
      act: (bloc) => bloc.add(const NotificationMarkReadRequested('n-1')),
      expect: () => [
        predicate<NotificationsState>(
          (state) => state.notifications.first.isRead,
        ),
        predicate<NotificationsState>(
          (state) =>
              !state.notifications.first.isRead && state.unreadCount == 1,
        ),
      ],
    );

    blocTest<NotificationsBloc, NotificationsState>(
      'ignores mark-read requests for already-read notifications',
      build: buildBloc,
      seed: () => NotificationsState(notifications: [readNotification]),
      act: (bloc) => bloc.add(const NotificationMarkReadRequested('n-2')),
      expect: () => <NotificationsState>[],
      verify: (_) {
        verifyNever(() => markRead(any()));
      },
    );
  });
}
