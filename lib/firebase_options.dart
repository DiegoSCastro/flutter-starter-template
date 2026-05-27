import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import 'core/config/env_config.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static final _env = const EnvConfig();

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _env.androidApiKey,
    appId: _env.androidAppId,
    messagingSenderId: _env.androidMessagingSenderId,
    projectId: _env.androidProjectId,
    storageBucket: _env.androidStorageBucket,
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _env.iosApiKey,
    appId: _env.iosAppId,
    messagingSenderId: _env.iosMessagingSenderId,
    projectId: _env.iosProjectId,
    storageBucket: _env.iosStorageBucket,
    iosClientId: _env.iosClientId,
    iosBundleId: _env.iosBundleId,
  );
}
