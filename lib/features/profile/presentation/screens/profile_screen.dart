import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/animation/widget_animations.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/theme/theme_state.dart';
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
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 24),
          const _SectionLabel('Appearance').animateSlideRight(delay: 350.ms),
          const _ThemeModeSelector().animateSlideRight(delay: 400.ms),
          const SizedBox(height: 8),
          const _ColorSchemeSelector().animateSlideRight(delay: 450.ms),
          const SizedBox(height: 24),
          const _SectionLabel('About').animateSlideRight(delay: 500.ms),
          const _AppInfoTile().animateSlideRight(delay: 550.ms),
          const SizedBox(height: 32),
          const _SignOutButton().animateSlideUp(delay: 600.ms),
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
            ).animateScale(),
            const SizedBox(height: 12),
            Text(
              username,
              style: theme.textTheme.titleLarge,
            ).animateSlideDown(delay: 150.ms),
            const SizedBox(height: 4),
            _CopyableId(id: id).animateFadeIn(delay: 250.ms),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID copied')));
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return RadioGroup<ThemeMode>(
          groupValue: state.mode,
          onChanged: (selected) {
            if (selected != null) {
              context.read<ThemeCubit>().setMode(selected);
            }
          },
          child: Column(
            children: ThemeMode.values.map((option) {
              return RadioListTile<ThemeMode>(
                value: option,
                title: Text(_labelFor(option)),
                secondary: Icon(_iconFor(option)),
              );
            }).toList(),
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

class _ColorSchemeSelector extends StatelessWidget {
  const _ColorSchemeSelector();

  static const _schemes = [
    FlexScheme.material,
    FlexScheme.deepPurple,
    FlexScheme.indigo,
    FlexScheme.blue,
    FlexScheme.green,
    FlexScheme.red,
    FlexScheme.mango,
    FlexScheme.gold,
    FlexScheme.sakura,
    FlexScheme.hippieBlue,
    FlexScheme.aquaBlue,
    FlexScheme.jungle,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _schemes.map((scheme) {
              final isActive = scheme == state.scheme;
              return GestureDetector(
                onTap: () => context.read<ThemeCubit>().setScheme(scheme),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: isActive ? 3 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _schemeColors(scheme),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Color> _schemeColors(FlexScheme scheme) => switch (scheme) {
    FlexScheme.material => const [Color(0xFF6750A4), Color(0xFFB4B0D0)],
    FlexScheme.deepPurple => const [Color(0xFF673AB7), Color(0xFFB39DDB)],
    FlexScheme.indigo => const [Color(0xFF3F51B5), Color(0xFF9FA8DA)],
    FlexScheme.blue => const [Color(0xFF2196F3), Color(0xFF90CAF9)],
    FlexScheme.green => const [Color(0xFF4CAF50), Color(0xFFA5D6A7)],
    FlexScheme.red => const [Color(0xFFF44336), Color(0xFFEF9A9A)],
    FlexScheme.mango => const [Color(0xFFFF9800), Color(0xFFFFCC80)],
    FlexScheme.gold => const [Color(0xFFFFC107), Color(0xFFFFE082)],
    FlexScheme.sakura => const [Color(0xFFE91E63), Color(0xFFF48FB1)],
    FlexScheme.hippieBlue => const [Color(0xFF4A90A2), Color(0xFFA8D8C8)],
    FlexScheme.aquaBlue => const [Color(0xFF03A9F4), Color(0xFF81D4FA)],
    FlexScheme.jungle => const [Color(0xFF388E3C), Color(0xFFA5D6A7)],
    _ => const [Color(0xFF9E9E9E), Color(0xFFBDBDBD)],
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
