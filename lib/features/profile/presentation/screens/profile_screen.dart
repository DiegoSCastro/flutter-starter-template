import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      padding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: const [
          _ProfileHeader(),
          SizedBox(height: 24),
          _SectionLabel('Appearance'),
          _ThemeModeSelector(),
          SizedBox(height: 24),
          _SectionLabel('About'),
          _AppInfoTile(),
          SizedBox(height: 32),
          _SignOutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final username = user?.username ?? '';
        final id = user?.id ?? '';
        final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';
        return Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                initial,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(username, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            _CopyableId(id: id),
          ],
        );
      },
    );
  }
}

class _CopyableId extends StatelessWidget {
  const _CopyableId({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (id.isEmpty) return const SizedBox.shrink();
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Clipboard.setData(ClipboardData(text: id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID copied')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              id,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.copy,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        return RadioGroup<ThemeMode>(
          groupValue: mode,
          onChanged: (selected) {
            if (selected != null) {
              context.read<ThemeCubit>().setMode(selected);
            }
          },
          child: Column(
            children: [
              for (final option in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: option,
                  title: Text(_labelFor(option)),
                  secondary: Icon(_iconFor(option)),
                ),
            ],
          ),
        );
      },
    );
  }

  String _labelFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'System default',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  IconData _iconFor(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };
}

class _AppInfoTile extends StatefulWidget {
  const _AppInfoTile();

  @override
  State<_AppInfoTile> createState() => _AppInfoTileState();
}

class _AppInfoTileState extends State<_AppInfoTile> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(info?.appName ?? '—'),
      subtitle: info == null
          ? const Text('Loading…')
          : Text('Version ${info.version} (build ${info.buildNumber})'),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AppButton(
        label: 'Sign out',
        icon: Icons.logout,
        variant: AppButtonVariant.tonal,
        expand: true,
        onPressed: () => context.read<AuthCubit>().signOut(),
      ),
    );
  }
}
