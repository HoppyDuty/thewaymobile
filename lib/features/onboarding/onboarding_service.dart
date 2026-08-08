import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/hive_setup.dart';

part 'onboarding_service.g.dart';

const _seenOnboardingKey = 'has_seen_onboarding';

class OnboardingService {
  bool get hasSeenOnboarding => HiveSetup.settingsBox.get(_seenOnboardingKey, defaultValue: false) as bool;

  Future<void> markSeen() => HiveSetup.settingsBox.put(_seenOnboardingKey, true);
}

@Riverpod(keepAlive: true)
OnboardingService onboardingService(OnboardingServiceRef ref) => OnboardingService();
