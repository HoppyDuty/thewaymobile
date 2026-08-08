import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/profile_models.dart';
import '../../data/profile_api.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<FullProfile> build() {
    return ref.watch(profileApiProvider).getFullProfile();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateProfile({String? firstName, String? lastName, String? phone}) async {
    final updatedUser = await ref
        .read(profileApiProvider)
        .updateProfile(firstName: firstName, lastName: lastName, phone: phone);

    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(
      FullProfile(user: updatedUser, stats: current.stats, preferences: current.preferences, leaderboard: current.leaderboard),
    );
  }

  Future<void> updateAvatar(String filePath) async {
    final avatarUrl = await ref.read(profileApiProvider).updateAvatar(filePath);
    final current = state.valueOrNull;
    if (current == null) return;

    final updatedUser = ProfileUser(
      id: current.user.id,
      uuid: current.user.uuid,
      firstName: current.user.firstName,
      lastName: current.user.lastName,
      fullName: current.user.fullName,
      username: current.user.username,
      email: current.user.email,
      phone: current.user.phone,
      avatarUrl: avatarUrl,
      referralCode: current.user.referralCode,
      role: current.user.role,
      status: current.user.status,
      isVerified: current.user.isVerified,
      memberSince: current.user.memberSince,
      lastLoginAt: current.user.lastLoginAt,
    );
    state = AsyncData(
      FullProfile(user: updatedUser, stats: current.stats, preferences: current.preferences, leaderboard: current.leaderboard),
    );
  }
}
