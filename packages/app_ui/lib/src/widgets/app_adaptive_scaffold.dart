import 'package:flutter/material.dart';

import '../layout/app_breakpoints.dart';

/// A single destination in the [AppAdaptiveScaffold] navigation.
@immutable
class AppDestination {
  const AppDestination({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
    this.hasBadge = false,
  }) : selectedIcon = selectedIcon ?? icon;

  /// Icon shown when the destination is not selected.
  final IconData icon;

  /// Icon shown when the destination is selected.
  final IconData selectedIcon;

  /// Label shown beside or under the icon.
  final String label;

  /// Whether to show a badge on the icon.
  final bool hasBadge;
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
            extendBody: true,
            body: body,
            bottomNavigationBar: _FloatingBottomBar(
              destinations: destinations,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
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
                      icon: Badge(
                        isLabelVisible: d.hasBadge,
                        child: Icon(d.icon),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: d.hasBadge,
                        child: Icon(d.selectedIcon),
                      ),
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

/// A floating, pill-shaped bottom navigation bar.
///
/// The selected destination expands into a tinted pill that reveals its label,
/// while the others collapse to icons. The bar floats above the body with a
/// rounded surface and a soft shadow for a lifted, tactile feel.
class _FloatingBottomBar extends StatelessWidget {
  const _FloatingBottomBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<AppDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    _BottomBarItem(
                      destination: destinations[index],
                      selected: index == selectedIndex,
                      onTap: () => onDestinationSelected(index),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single tappable destination within the [_FloatingBottomBar].
class _BottomBarItem extends StatelessWidget {
  const _BottomBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = selected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: _duration,
          curve: _curve,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.secondaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: _duration,
                child: Badge(
                  isLabelVisible: destination.hasBadge,
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    key: ValueKey<bool>(selected),
                    color: foreground,
                    size: 24,
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedAlign(
                  duration: _duration,
                  curve: _curve,
                  alignment: Alignment.centerLeft,
                  widthFactor: selected ? 1 : 0,
                  child: AnimatedOpacity(
                    duration: _duration,
                    curve: _curve,
                    opacity: selected ? 1 : 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        style: textTheme.labelLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
