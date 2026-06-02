import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/extensions/build_context_extensions.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';

/// Hosts the persistent adaptive navigation around the authenticated branches.
///
/// Renders an [AppAdaptiveScaffold] whose body is the [navigationShell] (the
/// indexed stack of branch navigators), so each destination keeps its own
/// navigation stack.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<NotificationsBloc>(),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          final l10n = context.l10n;
          final destinations = [
            AppDestination(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: l10n.navHome,
            ),
            AppDestination(
              icon: Icons.bookmark_outline,
              selectedIcon: Icons.bookmark,
              label: l10n.navBookmarks,
            ),
            AppDestination(
              icon: Icons.notifications_outlined,
              selectedIcon: Icons.notifications,
              label: l10n.navNotifications,
              hasBadge: state.unreadCount > 0,
            ),
            AppDestination(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: l10n.navProfile,
            ),
          ];

          return AppAdaptiveScaffold(
            destinations: destinations,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            body: navigationShell,
          );
        },
      ),
    );
  }
}
