import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_logo.dart';

/// Shown while [AuthSessionController] bootstraps (checks secure storage,
/// refreshes the cached profile) and [AppGateController] checks version/
/// maintenance state. The router's redirect logic moves on to force-update/
/// maintenance/onboarding/login/home the moment those resolve — this screen
/// has no navigation logic of its own, it's purely the brand-forward
/// "loading" visual (`UI_UX_RULES.md` §9).
///
/// The entrance motion is short and non-looping by design: it should read
/// as "the app arriving," not as a decorative animation the user waits out.
/// Nothing here blocks on network — bootstrap work happens independently in
/// the providers the router is watching.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: 112),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'The Way',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const CupertinoActivityIndicator(radius: 11),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
