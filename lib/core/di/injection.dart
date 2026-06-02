import 'package:core_analytics/core_analytics.dart';
import 'package:core_config/core_config.dart';
import 'package:core_network/core_network.dart';
import 'package:core_platform/core_platform.dart';
import 'package:core_theme/core_theme.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Async because core database modules use `@preResolve` to open native
/// resources before any consumer is constructed. Must be awaited from `main`.
///
/// `core_analytics` is registered before `core_platform` and `core_theme`
/// because both depend on `AnalyticsService` (the former via
/// `FirebaseMessagingService`, the latter via `ThemeBloc`).
@InjectableInit(
  externalPackageModulesBefore: [
    ExternalModule(CoreAnalyticsPackageModule),
    ExternalModule(CoreConfigPackageModule),
    ExternalModule(CoreNetworkPackageModule),
    ExternalModule(CorePlatformPackageModule),
    ExternalModule(CoreThemePackageModule),
  ],
)
Future<void> configureDependencies() async {
  await getIt.init();
}
