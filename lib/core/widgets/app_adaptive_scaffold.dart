import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// A single destination in the [AppAdaptiveScaffold] navigation.
@immutable
class AppDestination {
  const AppDestination({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected.
  final IconData selectedIcon;

  /// Label shown beside or under the icon.
  final String label;
}

/// Scaffolding that adapts its navigation affordance to the available width.
///
/// - Compact (`< [AppBreakpoints.medium]`): a bottom [NavigationBar].
/// - Medium (`< [AppBreakpoints.expanded]`): a collapsed [NavigationRail].
/// - Expanded: an extended [NavigationRail] with labels.
///
/// [body] is expected to be a branch's own `Scaffold` (with its app bar and
/// any floating action button); this widget only supplies the navigation
/// chrome around it.
class AppAdaptiveScaffold extends StatelessWidget {
  const AppAdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
  }) : assert(destinations.length >= 2, 'Need at least two destinations.');

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < AppBreakpoints.medium) {
          return Scaffold(
            body: body,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            ),
          );
        }

        final extended = width >= AppBreakpoints.expanded;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                extended: extended,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
