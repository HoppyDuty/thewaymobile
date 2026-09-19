import 'package:flutter/material.dart';

/// Brand palette — kept identical to the Filament admin panel
/// (see `AdminPanelProvider::panel()` in the backend) so the mobile app
/// and the admin dashboard read as the same product.
///
/// [brandBlue]/[brandGold] seed `ColorScheme.fromSeed` in `app_theme.dart` —
/// for anything role-based (background/surface/text/outline), read
/// `Theme.of(context).colorScheme` instead of this file, so light/dark mode
/// stay correct. The tonal ramps below exist for the cases a `ColorScheme`
/// role doesn't cover: a specific shade for a badge fill, a chip border, a
/// gold accent on a light card, etc. — see `docs/UI_UX_RULES.md` §2-3.
abstract final class AppColors {
  static const Color brandBlue = Color(0xFF1A237E);
  static const Color brandGold = Color(0xFFD4AF37);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color danger = Color(0xFFC62828);
  static const Color info = Color(0xFF0288D1);

  // ─── Blue tonal ramp (seeded from brandBlue = blue700) ────────────────────
  static const Color blue50 = Color(0xFFEAECF9);
  static const Color blue100 = Color(0xFFC5CBEE);
  static const Color blue200 = Color(0xFF9BA6E1);
  static const Color blue300 = Color(0xFF6E7DD3);
  static const Color blue400 = Color(0xFF4759C7);
  static const Color blue500 = Color(0xFF2739BC);
  static const Color blue600 = Color(0xFF2030A8);
  static const Color blue700 = brandBlue; // 0xFF1A237E
  static const Color blue800 = Color(0xFF131A63);
  static const Color blue900 = Color(0xFF0D1247);

  // ─── Gold tonal ramp (seeded from brandGold = gold500) ─────────────────────
  static const Color gold50 = Color(0xFFFBF6E8);
  static const Color gold100 = Color(0xFFF4E7BE);
  static const Color gold200 = Color(0xFFECD794);
  static const Color gold300 = Color(0xFFE3C76A);
  static const Color gold400 = Color(0xFFDABB4C);
  static const Color gold500 = brandGold; // 0xFFD4AF37
  static const Color gold600 = Color(0xFFB8952A);
  static const Color gold700 = Color(0xFF8F7420);
  static const Color gold800 = Color(0xFF665317);
  static const Color gold900 = Color(0xFF3D310E);

  // ─── Neutrals for the rare case a screen genuinely needs a fixed value
  // outside light/dark theming (e.g. a shadow color, a scrim) — prefer
  // ColorScheme roles for anything that should adapt to dark mode.
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral950 = Color(0xFF0A0B10);
  static const Color scrim = Color(0x66000000);
}
