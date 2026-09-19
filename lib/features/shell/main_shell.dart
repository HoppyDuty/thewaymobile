import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';
import '../../core/widgets/floating_nav_bar.dart';

const _destinations = [
  NavBarDestination(icon: AppIcons.home, selectedIcon: AppIcons.homeSelected, label: 'Home'),
  NavBarDestination(icon: AppIcons.cbt, selectedIcon: AppIcons.cbtSelected, label: 'CBT'),
  NavBarDestination(icon: AppIcons.video, selectedIcon: AppIcons.videoSelected, label: 'Videos'),
  NavBarDestination(icon: AppIcons.book, selectedIcon: AppIcons.bookSelected, label: 'Books'),
  NavBarDestination(icon: AppIcons.profile, selectedIcon: AppIcons.profileSelected, label: 'Profile'),
];

/// The 5-tab bottom nav shell (Home, CBT, Videos, Books, Profile —
/// `app_flow.md`/`phased_prd.md` Phase 3). Wraps `go_router`'s
/// `StatefulShellRoute.indexedStack` so each tab keeps its own navigation
/// stack and scroll position when switching between tabs. Uses the floating
/// nav bar (`UI_UX_RULES.md` §8) for the visual chrome; the navigation
/// mechanics (`goBranch`/`initialLocation`) are unchanged from before.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Not extendBody: true — that would require every tab's scroll view to
    // add matching bottom padding so content isn't obscured by the floating
    // bar. Keeping the body constrained above it is the safer default; a
    // future pass can opt specific screens into extending behind it.
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: FloatingNavBar(
        destinations: _destinations,
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
