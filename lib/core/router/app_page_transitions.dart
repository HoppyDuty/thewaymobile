import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_motion.dart';

/// Combined fade-through + subtle forward-slide transition used for every
/// route in the app (`uiuxrules.md` §4 — "smooth, short, avoid unnecessary
/// animation," "use different transitions intentionally"). Wrap a route's
/// `builder` result with this via `pageBuilder` instead of `builder` to get
/// a consistent forward-navigation feel everywhere.
CustomTransitionPage<void> buildPageWithTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: AppCurves.enter);
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.standard));

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Vertical slide-up, used for modal-style full-screen flows (payment
/// checkout, exam session) where a bottom-sheet-like entrance reads better
/// than the standard forward transition.
CustomTransitionPage<void> buildModalPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppCurves.standard));
      final fade = CurvedAnimation(parent: animation, curve: AppCurves.enter);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
