import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class NavBarDestination {
  const NavBarDestination({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating bottom navigation (`UI_UX_RULES.md` §8) — a lightweight, inset,
/// rounded bar rather than a full-width docked Material `NavigationBar`.
/// Purely presentational: `MainShell` still owns the actual navigation
/// (`StatefulNavigationShell.goBranch`), this widget just renders the
/// current index and reports taps.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final List<NavBarDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, bottomInset > 0 ? AppSpacing.sm : AppSpacing.md),
      child: Material(
        elevation: 8,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.xlRadius,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.destination, required this.selected, required this.onTap});

  final NavBarDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        customBorder: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppDurations.fast,
              curve: AppCurves.standard,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Icon(selected ? destination.selectedIcon : destination.icon, color: color, size: 22),
            ),
            const SizedBox(height: 3),
            Text(
              destination.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
