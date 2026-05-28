import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

part '../widgets/profile_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const _ProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return AppScaffold(
          title: 'Profile',
          padding: EdgeInsets.zero,
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              const _SectionLabel(
                'Appearance',
              ).animateSlideRight(delay: 350.ms),
              const _ThemeModeSelector().animateSlideRight(delay: 400.ms),
              const SizedBox(height: 8),
              const _ColorSchemeSelector().animateSlideRight(delay: 450.ms),
              const SizedBox(height: 24),
              const _SectionLabel('About').animateSlideRight(delay: 500.ms),
              const _AppInfoTile().animateSlideRight(delay: 550.ms),
              const SizedBox(height: 32),
              _SignOutButton(
                isLoading: state.isSigningOut,
              ).animateSlideUp(delay: 600.ms),
            ],
          ),
        );
      },
    );
  }
}
