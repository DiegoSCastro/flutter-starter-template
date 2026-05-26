import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/sign_in.dart';
import '../features/auth/domain/usecases/sign_out.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final repository = AuthRepositoryImpl(InMemoryAuthDataSource());
        return AuthCubit(
          signIn: SignIn(repository),
          signOut: SignOut(repository),
        );
      },
      child: MaterialApp(
        title: 'Flutter Starter',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => switch (state) {
            AuthAuthenticated(:final user) => HomeScreen(user: user),
            _ => const LoginScreen(),
          },
        ),
      ),
    );
  }
}
