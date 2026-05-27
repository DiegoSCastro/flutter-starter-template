import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

/// Provides the third-party plugin instance so [NotificationsService] can
/// receive it via constructor injection.
@module
abstract class NotificationsModule {
  @lazySingleton
  FlutterLocalNotificationsPlugin providePlugin() =>
      FlutterLocalNotificationsPlugin();
}
