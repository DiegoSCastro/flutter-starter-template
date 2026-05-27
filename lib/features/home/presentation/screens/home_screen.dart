import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return AppScaffold(
      title: l.homeAppBarTitle,
      padding: const EdgeInsets.all(24),
      actions: const [_ProfileAvatarButton()],
      body: Center(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final username =
                state is AuthAuthenticated ? state.user.username : '';
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ).animateScale(delay: 100.ms),
                const SizedBox(height: 16),
                Text(
                  l.homeWelcome(username),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ).animateSlideDown(delay: 200.ms),
                const SizedBox(height: 8),
                Text(l.homeSignedInBody, style: theme.textTheme.bodyMedium)
                    .animateFadeIn(delay: 300.ms),
                const SizedBox(height: 24),
                AppButton(
                  label: 'My bookmarks',
                  icon: Icons.bookmark_outline,
                  onPressed: () => context.push('/bookmarks'),
                ).animateSlideUp(delay: 400.ms),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final username =
            state is AuthAuthenticated ? state.user.username : '';
        final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
