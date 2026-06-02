import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../layout/app_breakpoints.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A single destination in the [AppAdaptiveScaffold] navigation.
@immutable
class AppDestination {
  const AppDestination({
    required this.icon,
    required this.label,
    FaIconData? selectedIcon,
    this.hasBadge = false,
  }) : selectedIcon = selectedIcon ?? icon;

  /// Icon shown when the destination is not selected.
  final FaIconData icon;

  /// Icon shown when the destination is selected.
  final FaIconData selectedIcon;

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
                        child: FaIcon(d.icon),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: d.hasBadge,
                        child: FaIcon(d.selectedIcon),
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
      minimum: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Material(
              color: colorScheme.surfaceContainer.withValues(alpha: 0.96),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
              elevation: 8,
              child: SizedBox(
                height: 72,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: [
                      for (var index = 0; index < destinations.length; index++)
                        Expanded(
                          child: _BottomBarItem(
                            destination: destinations[index],
                            selected: index == selectedIndex,
                            onTap: () => onDestinationSelected(index),
                          ),
                        ),
                    ],
                  ),
                ),
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
      child: Tooltip(
        message: destination.label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  width: selected ? 54 : 38,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.secondaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: AnimatedSwitcher(
                    duration: _duration,
                    child: Badge(
                      isLabelVisible: destination.hasBadge,
                      child: FaIcon(
                        selected ? destination.selectedIcon : destination.icon,
                        key: ValueKey<bool>(selected),
                        color: foreground,
                        size: 21,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                AnimatedDefaultTextStyle(
                  duration: _duration,
                  curve: _curve,
                  style:
                      textTheme.labelSmall?.copyWith(
                        color: selected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ) ??
                      TextStyle(
                        color: selected
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
