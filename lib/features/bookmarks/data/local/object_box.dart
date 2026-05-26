import 'package:path_provider/path_provider.dart';

import '../../../../objectbox.g.dart';

/// Owns the lifecycle of the ObjectBox [Store]. There must be exactly one
/// store per database path per process — opening twice throws — so this is
/// constructed once during app bootstrap and held as a singleton in the DI
/// container.
class ObjectBox {
  ObjectBox._(this.store);

  final Store store;

  /// Opens the database at `<appDocsDir>/objectbox`. Must be awaited before
  /// any DI lookups that depend on the store.
  static Future<ObjectBox> open() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: '${docsDir.path}/objectbox');
    return ObjectBox._(store);
  }

  void close() => store.close();
}
