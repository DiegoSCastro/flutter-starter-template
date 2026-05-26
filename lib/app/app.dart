import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/counter/data/datasources/counter_local_data_source.dart';
import '../features/counter/data/repositories/counter_repository_impl.dart';
import '../features/counter/domain/usecases/increment_counter.dart';
import '../features/counter/presentation/screens/counter_screen.dart';
import '../features/counter/presentation/viewmodels/counter_viewmodel.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final CounterViewModel _counterViewModel;

  @override
  void initState() {
    super.initState();
    final repository = CounterRepositoryImpl(InMemoryCounterDataSource());
    _counterViewModel = CounterViewModel(
      repository: repository,
      increment: IncrementCounter(repository),
    );
  }

  @override
  void dispose() {
    _counterViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Starter',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: CounterScreen(
        viewModel: _counterViewModel,
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}
