import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_cubit.dart';
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
      actions: [
        const _ThemeToggleButton(),
        IconButton(
          tooltip: l.homeSignOutTooltip,
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthCubit>().signOut(),
        ),
      ],
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
                ),
                const SizedBox(height: 16),
                Text(
                  l.homeWelcome(username),
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(l.homeSignedInBody, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                AppButton(
                  label: 'My bookmarks',
                  icon: Icons.bookmark_outline,
                  onPressed: () => context.push('/bookmarks'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final (icon, tooltip) = switch (mode) {
          ThemeMode.light => (Icons.light_mode, 'Light theme'),
          ThemeMode.dark => (Icons.dark_mode, 'Dark theme'),
          ThemeMode.system => (Icons.brightness_auto, 'System theme'),
        };
        return IconButton(
          tooltip: tooltip,
          icon: Icon(icon),
          onPressed: () => context.read<ThemeCubit>().toggle(),
        );
      },
    );
  }
}
