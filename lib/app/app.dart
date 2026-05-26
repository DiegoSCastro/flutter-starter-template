import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/sign_in.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import 'router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final repository = AuthRepositoryImpl(InMemoryAuthDataSource());
    _authCubit = AuthCubit(
      signIn: SignIn(repository),
      signOut: SignOut(repository),
    );
    _router = buildRouter(_authCubit);
  }

  @override
  void dispose() {
    _router.dispose();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: MaterialApp.router(
        title: 'Flutter Starter',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: _router,
      ),
    );
  }
}
