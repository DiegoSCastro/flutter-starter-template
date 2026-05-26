import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/sign_in.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../features/home/presentation/screens/home_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    final repository = AuthRepositoryImpl(InMemoryAuthDataSource());
    _authViewModel = AuthViewModel(
      signIn: SignIn(repository),
      signOut: SignOut(repository),
    );
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Starter',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: ListenableBuilder(
        listenable: _authViewModel,
        builder: (context, _) => _authViewModel.isAuthenticated
            ? HomeScreen(viewModel: _authViewModel)
            : LoginScreen(viewModel: _authViewModel),
      ),
    );
  }
}
