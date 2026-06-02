import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/bootstrap_error_app.dart';
import 'core/config/remote_config_service.dart';
import 'core/di/injection.dart';
import 'core/platform/firebase/firebase_service.dart';
import 'core/platform/notifications/firebase_messaging_service.dart';
import 'core/platform/notifications/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await configureDependencies();

    await getIt<FirebaseService>().init();

    await getIt<RemoteConfigService>().init();

    await getIt<NotificationsService>().init();
    await getIt<FirebaseMessagingService>().init();
    runApp(const App());
  } on Object catch (error, stackTrace) {
    await _reportBootstrapFailure(error, stackTrace);
    runApp(BootstrapErrorApp(error: error));
  }
}

/// Records a fatal bootstrap failure. Always logs via `dart:developer`; also
/// reports to Crashlytics, but only if Firebase managed to initialize —
/// otherwise the report itself would throw and mask the original error.
Future<void> _reportBootstrapFailure(
  Object error,
  StackTrace stackTrace,
) async {
  developer.log(
    'App bootstrap failed',
    name: 'bootstrap',
    level: 1000,
    error: error,
    stackTrace: stackTrace,
  );

  if (Firebase.apps.isEmpty) return;
  try {
    await FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'App bootstrap failed',
      fatal: true,
    );
  } on Object catch (_) {
    // Crashlytics is best-effort here; the developer.log above still fired.
  }
}
