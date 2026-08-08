import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_api.dart';
import '../../data/models/leaderboard.dart';

part 'leaderboard_controller.g.dart';

@riverpod
class LeaderboardController extends _$LeaderboardController {
  @override
  Future<Leaderboard> build() {
    return ref.watch(homeApiProvider).getLeaderboard();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeApiProvider).getLeaderboard());
  }
}
