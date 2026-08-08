import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../providers/preferences_controller.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  Future<void> _handle(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(preferencesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(preferencesControllerProvider),
        ),
        data: (prefs) {
          final notifier = ref.read(preferencesControllerProvider.notifier);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text('Appearance', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                child: Column(
                  children: [
                    for (final option in const [
                      (value: 'system', label: 'Match Device'),
                      (value: 'light', label: 'Light'),
                      (value: 'dark', label: 'Dark'),
                    ])
                      RadioListTile<String>(
                        title: Text(option.label),
                        value: option.value,
                        // ignore: deprecated_member_use
                        groupValue: prefs.theme,
                        // ignore: deprecated_member_use
                        onChanged: (value) => _handle(context, () => notifier.setTheme(value!)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Notifications', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Card(
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      value: prefs.pushNotificationsEnabled,
                      onChanged: (v) => _handle(context, () => notifier.setPushNotificationsEnabled(v)),
                    ),
                    SwitchListTile(
                      title: const Text('Email Notifications'),
                      value: prefs.emailNotificationsEnabled,
                      onChanged: (v) => _handle(context, () => notifier.setEmailNotificationsEnabled(v)),
                    ),
                    SwitchListTile(
                      title: const Text('Exam Reminders'),
                      value: prefs.examRemindersEnabled,
                      onChanged: (v) => _handle(context, () => notifier.setExamRemindersEnabled(v)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
