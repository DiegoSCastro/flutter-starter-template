import 'package:flutter_starter_template/core/error/failure.dart';
import 'package:flutter_starter_template/core/utils/result.dart';
import 'package:flutter_starter_template/features/notifications/domain/entities/notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/get_notifications_feed.dart';
import 'package:flutter_starter_template/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsRepository extends Mock
    implements NotificationsRepository {}

void main() {
  late MockNotificationsRepository repository;

  setUp(() {
    repository = MockNotificationsRepository();
  });

  group('GetNotificationsFeed', () {
    test('delegates to repository', () async {
      when(
        () => repository.getFeed(),
      ).thenAnswer((_) async => const Ok(NotificationsFeed.empty));

      final result = await GetNotificationsFeed(repository)();

      expect(result, isA<Ok<NotificationsFeed>>());
      verify(() => repository.getFeed()).called(1);
    });

    test('maps thrown errors to UnknownFailure', () async {
      when(() => repository.getFeed()).thenThrow(Exception('offline'));

      final result = await GetNotificationsFeed(repository)();

      expect(result, isA<Err<NotificationsFeed>>());
      expect(
        (result as Err<NotificationsFeed>).failure,
        isA<UnknownFailure>(),
      );
    });
  });

  group('MarkNotificationRead', () {
    test('delegates to repository', () async {
      when(
        () => repository.markRead('n-1'),
      ).thenAnswer((_) async => const Ok(null));

      final result = await MarkNotificationRead(repository)('n-1');

      expect(result, isA<Ok<void>>());
      verify(() => repository.markRead('n-1')).called(1);
    });

    test('maps thrown errors to UnknownFailure', () async {
      when(() => repository.markRead('n-1')).thenThrow(Exception('offline'));

      final result = await MarkNotificationRead(repository)('n-1');

      expect(result, isA<Err<void>>());
      expect((result as Err<void>).failure, isA<UnknownFailure>());
    });
  });
}
