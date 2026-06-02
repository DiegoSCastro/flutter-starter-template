import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Registers third-party services that the bookmarks data layer depends on.
@module
abstract class BookmarksDataModule {
  @lazySingleton
  Connectivity provideConnectivity() => Connectivity();

  @lazySingleton
  Uuid provideUuid() => const Uuid();
}
