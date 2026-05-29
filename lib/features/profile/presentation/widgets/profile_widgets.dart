import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/router.dart';
import '../../../../core/analytics/analytics_extensions.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/animation/widget_animations.dart';
import '../../../../core/build_context_extensions.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/future_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../../../../core/theme/theme_state.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: context.l10n.profileAppBarTitle,
      padding: EdgeInsets.zero,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel(
            context.l10n.profileSectionAccount,
          ).animateSlideRight(delay: 300.ms),
          const _ChangePasswordTile().animateSlideRight(delay: 325.ms),
          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel(
            context.l10n.profileSectionAppearance,
          ).animateSlideRight(delay: 350.ms),
          const _ThemeModeSelector().animateSlideRight(delay: 400.ms),
          const SizedBox(height: AppSpacing.sm),
          const _ColorSchemeSelector().animateSlideRight(delay: 450.ms),
          const SizedBox(height: AppSpacing.xxl),
          _SectionLabel(
            context.l10n.profileSectionAbout,
          ).animateSlideRight(delay: 500.ms),
          const _AppInfoTile().animateSlideRight(delay: 550.ms),
          const SizedBox(height: AppSpacing.xxxl),
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
    return BlocSelector<AuthBloc, AuthState, AuthUser?>(
      selector: (state) => switch (state) {
        AuthAuthenticated(:final user) || AuthSigningOut(:final user) => user,
        _ => null,
      },
      builder: (context, user) {
        final username = user?.username ?? '';
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
            const SizedBox(height: AppSpacing.md),
            Text(
              username,
              style: theme.textTheme.titleLarge,
            ).animateSlideDown(delay: 150.ms),
            const SizedBox(height: AppSpacing.xs),
            _CopyableId(id: user?.id ?? '').animateFadeIn(delay: 250.ms),
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
        getIt<AnalyticsService>().trackUserIdCopied().uw();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileUserIdCopied)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              id,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return RadioGroup<ThemeMode>(
          groupValue: state.mode,
          onChanged: (selected) {
            if (selected != null) {
              context.read<ThemeBloc>().add(ThemeModeChanged(selected));
            }
          },
          child: Column(
            children: ThemeMode.values.map((option) {
              return RadioListTile<ThemeMode>(
                value: option,
                title: Text(_labelFor(context, option)),
                secondary: Icon(_iconFor(option)),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _labelFor(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.l10n.profileThemeSystemDefault,
    ThemeMode.light => context.l10n.profileThemeLight,
    ThemeMode.dark => context.l10n.profileThemeDark,
  };

  IconData _iconFor(ThemeMode mode) => switch (mode) {
    ThemeMode.system => Icons.brightness_auto,
    ThemeMode.light => Icons.light_mode,
    ThemeMode.dark => Icons.dark_mode,
  };
}

class _ColorSchemeSelector extends StatelessWidget {
  const _ColorSchemeSelector();

  static const List<FlexScheme> _schemes = [
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _schemes.map((scheme) {
              final isActive = scheme == state.scheme;
              return GestureDetector(
                onTap: () =>
                    context.read<ThemeBloc>().add(ThemeSchemeChanged(scheme)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? context.colorScheme.primary
                          : context.colorScheme.outline.withValues(alpha: 0.3),
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

class _AppInfoTile extends StatelessWidget {
  const _AppInfoTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final info = state.packageInfo;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(info?.appName ?? '—'),
          subtitle: info == null
              ? Text(context.l10n.commonLoading)
              : Text(
                  context.l10n.profileAppVersionBuild(
                    info.version,
                    info.buildNumber,
                  ),
                ),
        );
      },
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) => state is AuthSigningOut,
      builder: (context, isLoading) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: AppButton(
            label: context.l10n.commonSignOut,
            icon: Icons.logout,
            variant: AppButtonVariant.tonal,
            expand: true,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _confirmSignOut(context),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.commonSignOut),
        content: Text(l10n.profileSignOutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.commonSignOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }
}

class _ChangePasswordTile extends StatelessWidget {
  const _ChangePasswordTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.password),
      title: Text(context.l10n.profileChangePassword),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        const ChangePasswordRoute().push<void>(context);
      },
    );
  }
}
