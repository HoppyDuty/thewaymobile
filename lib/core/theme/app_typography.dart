import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography (`uiuxrules.md` §19) — built on Google Fonts'
/// "Inter" (clean, highly legible at small sizes, widely used in premium
/// products) so every screen shares one hierarchy instead of ad hoc
/// `TextStyle`s.
abstract final class AppTypography {
  static TextTheme textTheme(ColorScheme colorScheme) {
    final base = GoogleFonts.interTextTheme();

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurface),
      bodyLarge: base.bodyLarge?.copyWith(color: colorScheme.onSurface, height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(color: colorScheme.onSurface, height: 1.4),
      bodySmall: base.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
    );
  }
}
