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
            context.l10n.profileSectionAbout,
          ).animateSlideRight(delay: 350.ms),
          const _AppInfoTile().animateSlideRight(delay: 400.ms),
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
