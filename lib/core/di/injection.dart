import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../../features/bookmarks/data/local/object_box.dart'
    show ObjectBoxModule;
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Async because [ObjectBoxModule] uses `@preResolve` to open the native
/// store before any consumer is constructed. Must be awaited from `main`.
@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}
