import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/user_activity.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_state.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        // First load with no cached content yet — defer to the failure / empty
        // states below once it settles.
        if (state.failure != null && state.hasNoContent) {
          return AppScaffold(
            title: context.l10n.notificationsAppBarTitle,
            body: AppErrorView(
              message: context.l10n.notificationsLoadError,
              onRetry: () => context.read<NotificationsBloc>().add(
                const NotificationsLoadRequested(),
              ),
            ),
          );
        }

        return AppScaffold(
          title: context.l10n.notificationsAppBarTitle,
          isLoading: state.isLoading && state.hasNoContent,
          padding: EdgeInsets.zero,
          body: const _NotificationsTabs(),
        );
      },
    );
  }
}

class _NotificationsTabs extends StatelessWidget {
  const _NotificationsTabs();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsBloc>().state;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: _NotificationsTabBar(state: state),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _NotificationsList(
                  notifications: state.notifications,
                  unreadCount: state.unreadCount,
                ),
                _ActivitiesList(activities: state.activities),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTabBar extends StatelessWidget {
  const _NotificationsTabBar({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: context.isDark ? 0.32 : 0.48,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: context.colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        labelColor: context.colorScheme.onSecondaryContainer,
        unselectedLabelColor: context.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          color: context.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        tabs: [
          Tab(
            child: _TabLabel(
              icon: FontAwesomeIcons.bell,
              label: context.l10n.notificationsSection,
              badgeCount: state.unreadCount,
            ),
          ),
          Tab(
            child: _TabLabel(
              icon: FontAwesomeIcons.clockRotateLeft,
              label: context.l10n.notificationsActivitySection,
              badgeCount: state.activities.length,
              showZero: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({
    required this.icon,
    required this.label,
    required this.badgeCount,
    this.showZero = false,
  });

  final FaIconData icon;
  final String label;
  final int badgeCount;
  final bool showZero;

  @override
  Widget build(BuildContext context) {
    final showBadge = badgeCount > 0 || showZero;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(icon, size: AppIconSize.sm),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showBadge) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              badgeCount.toString(),
              textAlign: TextAlign.center,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.notifications,
    required this.unreadCount,
  });

  final List<AppNotification> notifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader(
            title: context.l10n.notificationsSection,
            badgeCount: unreadCount,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (notifications.isEmpty)
            _TabEmptyState(
              icon: FontAwesomeIcons.bell,
              title: context.l10n.notificationsNoNotifications,
              message: context.l10n.notificationsEmptyMessage,
            )
          else
            for (final (index, notification) in notifications.indexed)
              _NotificationTile(
                notification: notification,
                onTap: () => context.read<NotificationsBloc>().add(
                  NotificationMarkReadRequested(notification.id),
                ),
              ).animateSlideUp(delay: (50 * index).ms),
        ],
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  const _ActivitiesList({required this.activities});

  final List<UserActivity> activities;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => _refresh(context),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _SectionHeader(title: context.l10n.notificationsActivitySection),
          const SizedBox(height: AppSpacing.sm),
          if (activities.isEmpty)
            _TabEmptyState(
              icon: FontAwesomeIcons.clockRotateLeft,
              title: context.l10n.notificationsEmptyTitle,
              message: context.l10n.notificationsEmptyMessage,
            )
          else
            for (final (index, activity) in activities.indexed)
              _ActivityTile(
                activity: activity,
              ).animateSlideUp(delay: (50 * index).ms),
        ],
      ),
    );
  }
}

Future<void> _refresh(BuildContext context) {
  final bloc = context.read<NotificationsBloc>()
    ..add(const NotificationsLoadRequested());
  // Keep the spinner visible until the reload settles.
  return bloc.stream.firstWhere((s) => !s.isLoading);
}

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final FaIconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: AppEmptyView(
        icon: icon,
        title: title,
        message: message,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.badgeCount = 0});

  final String title;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (badgeCount > 0) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Text(
              context.l10n.notificationsUnreadCount(badgeCount),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final UserActivity activity;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.colorScheme.secondaryContainer,
          child: FaIcon(
            _activityIcon(activity.type),
            color: context.colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(activity.description),
        subtitle: Text(formatRelativeTime(context, activity.createdAt)),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _notificationColor(context, notification.type);
    return Card(
      elevation: notification.isRead ? 0 : 1,
      color: notification.isRead
          ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
          : context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ListTile(
        onTap: notification.isRead ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.15),
          child: FaIcon(_notificationIcon(notification.type), color: accent),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              formatRelativeTime(context, notification.createdAt),
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}

FaIconData _activityIcon(UserActivityType type) => switch (type) {
  UserActivityType.created => FontAwesomeIcons.circlePlus,
  UserActivityType.updated => FontAwesomeIcons.penToSquare,
  UserActivityType.deleted => FontAwesomeIcons.trashCan,
  UserActivityType.signedIn => FontAwesomeIcons.arrowRightToBracket,
  UserActivityType.other => FontAwesomeIcons.clockRotateLeft,
};

FaIconData _notificationIcon(NotificationType type) => switch (type) {
  NotificationType.system => FontAwesomeIcons.circleInfo,
  NotificationType.social => FontAwesomeIcons.users,
  NotificationType.reminder => FontAwesomeIcons.clock,
  NotificationType.promotion => FontAwesomeIcons.tag,
};

Color _notificationColor(BuildContext context, NotificationType type) =>
    switch (type) {
      NotificationType.system => context.colorScheme.primary,
      NotificationType.social => context.semanticColors.info,
      NotificationType.reminder => context.semanticColors.warning,
      NotificationType.promotion => context.semanticColors.success,
    };

/// Formats [timestamp] as a compact, localized relative time
/// (e.g. "Just now", "5m ago", "3h ago", "2d ago", or an absolute date).
String formatRelativeTime(BuildContext context, DateTime timestamp) {
  final l10n = context.l10n;
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
  final local = timestamp.toLocal();
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}
