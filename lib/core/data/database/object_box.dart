import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../objectbox.g.dart';

/// Owns the lifecycle of the ObjectBox [Store]. There must be exactly one
/// store per database path per process — opening twice throws — so this is
/// constructed once during DI init (see [ObjectBoxModule]) and held as a
/// singleton.
class ObjectBox {
  ObjectBox._(this.store);

  final Store store;

  static Future<ObjectBox> open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${docsDir.path}/objectbox');
    return ObjectBox._(store);
  }

  void close() => store.close();
}

/// Bridges ObjectBox into the injectable DI graph. `@preResolve` makes
/// `configureDependencies()` async so the native store has a chance to open
/// before any consumer is constructed.
@module
abstract class ObjectBoxModule {
  @preResolve
  @singleton
  Future<ObjectBox> provideObjectBox() => ObjectBox.open();

  @singleton
  Store provideStore(ObjectBox objectBox) => objectBox.store;
}
