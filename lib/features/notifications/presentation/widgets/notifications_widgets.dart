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
          body: state.hasNoContent && !state.isLoading
              ? AppEmptyView(
                  icon: FontAwesomeIcons.bell,
                  title: context.l10n.notificationsEmptyTitle,
                  message: context.l10n.notificationsEmptyMessage,
                )
              : const _FeedList(),
        );
      },
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationsBloc>().state;
    return RefreshIndicator(
      onRefresh: () {
        final bloc = context.read<NotificationsBloc>()
          ..add(const NotificationsLoadRequested());
        // Keep the spinner visible until the reload settles.
        return bloc.stream.firstWhere((s) => !s.isLoading);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (state.activities.isNotEmpty) ...[
            _SectionHeader(title: context.l10n.notificationsActivitySection),
            const SizedBox(height: AppSpacing.sm),
            for (final (index, activity) in state.activities.indexed)
              _ActivityTile(
                activity: activity,
              ).animateSlideUp(delay: (50 * index).ms),
            const SizedBox(height: AppSpacing.xl),
          ],
          _SectionHeader(
            title: context.l10n.notificationsSection,
            badgeCount: state.unreadCount,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                context.l10n.notificationsNoNotifications,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            for (final (index, notification) in state.notifications.indexed)
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
