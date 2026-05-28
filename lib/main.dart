import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/firebase/firebase_service.dart';
import 'core/notifications/firebase_messaging_service.dart';
import 'core/notifications/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  await getIt<FirebaseService>().init();

  await getIt<NotificationsService>().init();
  await getIt<FirebaseMessagingService>().init();
  runApp(const App());
}
