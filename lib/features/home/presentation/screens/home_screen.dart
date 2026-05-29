import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final username = authState is AuthAuthenticated
        ? authState.user.username
        : '';
    return BlocProvider(
      create: (_) =>
          getIt<HomeBloc>()..add(HomeLoadRequested(username: username)),
      child: const HomeBody(),
    );
  }
}
