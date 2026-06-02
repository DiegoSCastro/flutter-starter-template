// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:analytics/src/analytics_module.dart' as _i79;
import 'package:analytics/src/analytics_route_observer.dart' as _i87;
import 'package:analytics/src/analytics_service.dart' as _i657;
import 'package:firebase_analytics/firebase_analytics.dart' as _i398;
import 'package:injectable/injectable.dart' as _i526;

class CoreAnalyticsPackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final analyticsModule = _$AnalyticsModule();
    gh.lazySingleton<_i398.FirebaseAnalytics>(
      () => analyticsModule.provideFirebaseAnalytics(),
    );
    gh.lazySingleton<_i657.AnalyticsService>(
      () => _i657.FirebaseAnalyticsService(gh<_i398.FirebaseAnalytics>()),
    );
    gh.lazySingleton<_i87.AnalyticsRouteObserver>(
      () => _i87.AnalyticsRouteObserver(gh<_i657.AnalyticsService>()),
    );
  }
}

class _$AnalyticsModule extends _i79.AnalyticsModule {}
