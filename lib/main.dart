import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/di/injection.dart';
import 'core/notifications/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<NotificationsService>().init();
  runApp(const App());
}
