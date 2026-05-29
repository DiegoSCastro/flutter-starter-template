import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(ProfileLoaded(user)),
      child: const ProfileBody(),
    );
  }
}
