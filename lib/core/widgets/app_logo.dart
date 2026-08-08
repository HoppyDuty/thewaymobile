import 'package:flutter/material.dart';

/// The real brand mark (`assets/images/logo.png`) — use this instead of
/// any placeholder wherever the app's logo needs to appear (splash,
/// onboarding, login header, about screen, etc.).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
