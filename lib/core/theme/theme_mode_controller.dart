import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/hive_setup.dart';

part 'theme_mode_controller.g.dart';

const _themeModeKey = 'theme_mode';

ThemeMode themeModeFromString(String value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

/// The app's current theme mode — read from Hive at boot (so it applies
/// instantly, before any network call), and reconciled with the server's
/// `UserPreference.theme` whenever the profile/preferences screen fetches
/// it, so the choice follows the user across reinstalls/devices.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    final stored = HiveSetup.settingsBox.get(_themeModeKey) as String?;
    return stored != null ? themeModeFromString(stored) : ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await HiveSetup.settingsBox.put(_themeModeKey, themeModeToString(mode));
  }

  /// Applies a theme value that came from the server without re-persisting
  /// it back — used when reconciling on profile load, to avoid an
  /// unnecessary round-trip PATCH echoing the same value back to itself.
  Future<void> applyFromServer(String theme) async {
    final mode = themeModeFromString(theme);
    if (mode == state) return;
    state = mode;
    await HiveSetup.settingsBox.put(_themeModeKey, theme);
  }
}
