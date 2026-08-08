import 'package:flutter/material.dart';

/// Brand palette — kept identical to the Filament admin panel
/// (see `AdminPanelProvider::panel()` in the backend) so the mobile app
/// and the admin dashboard read as the same product.
abstract final class AppColors {
  static const Color brandBlue = Color(0xFF1A237E);
  static const Color brandGold = Color(0xFFD4AF37);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);
}
