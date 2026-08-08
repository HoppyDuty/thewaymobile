import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/theme_mode_controller.dart';
import '../../data/models/profile_models.dart';
import '../../data/profile_api.dart';

part 'preferences_controller.g.dart';

@riverpod
class PreferencesController extends _$PreferencesController {
  @override
  Future<UserPreferences> build() async {
    final prefs = await ref.watch(profileApiProvider).getPreferences();
    // The server is the source of truth for theme once it's reachable —
    // reconcile the locally-applied theme (which boots instantly from Hive,
    // before this call can complete) with whatever the account actually
    // has saved, so switching devices carries the choice over.
    await ref.read(themeModeControllerProvider.notifier).applyFromServer(prefs.theme);
    return prefs;
  }

  Future<void> setTheme(String theme) async {
    await ref.read(themeModeControllerProvider.notifier).setThemeMode(themeModeFromString(theme));
    await _update(theme: theme);
  }

  Future<void> setPushNotificationsEnabled(bool value) => _update(pushNotificationsEnabled: value);
  Future<void> setEmailNotificationsEnabled(bool value) => _update(emailNotificationsEnabled: value);
  Future<void> setExamRemindersEnabled(bool value) => _update(examRemindersEnabled: value);

  Future<void> _update({
    String? theme,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? examRemindersEnabled,
  }) async {
    final previous = state;
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(
        UserPreferences(
          theme: theme ?? current.theme,
          pushNotificationsEnabled: pushNotificationsEnabled ?? current.pushNotificationsEnabled,
          emailNotificationsEnabled: emailNotificationsEnabled ?? current.emailNotificationsEnabled,
          examRemindersEnabled: examRemindersEnabled ?? current.examRemindersEnabled,
          preferredLanguage: current.preferredLanguage,
        ),
      );
    }

    try {
      final updated = await ref
          .read(profileApiProvider)
          .updatePreferences(
            theme: theme,
            pushNotificationsEnabled: pushNotificationsEnabled,
            emailNotificationsEnabled: emailNotificationsEnabled,
            examRemindersEnabled: examRemindersEnabled,
          );
      state = AsyncData(updated);
    } catch (_) {
      state = previous; // roll back the optimistic update
      rethrow;
    }
  }
}
