import 'package:flutter/material.dart';

import '../../core/widgets/app_logo.dart';

/// Shown while [AuthSessionController] bootstraps (checks secure storage,
/// refreshes the cached profile). The router's redirect logic moves on to
/// onboarding/login/home the moment that resolves — this screen itself
/// has no navigation logic, it's just the "loading" visual.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 120),
            const SizedBox(height: 24),
            Text('The Way', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
