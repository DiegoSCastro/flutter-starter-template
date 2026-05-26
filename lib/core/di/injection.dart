import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:objectbox/objectbox.dart';

import '../../features/bookmarks/data/local/object_box.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Wires DI. The [ObjectBox] handle must be opened by the caller (it needs
/// `await`), and is registered first so injectable-generated factories can
/// resolve [Store] from it.
@InjectableInit()
void configureDependencies({required ObjectBox objectBox}) {
  getIt
    ..registerSingleton<ObjectBox>(objectBox)
    ..registerSingleton<Store>(objectBox.store);
  getIt.init();
}
