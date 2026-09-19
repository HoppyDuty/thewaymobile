import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/stale_while_revalidate.dart';
import '../../data/home_api.dart';
import '../../data/models/leaderboard.dart';

part 'leaderboard_controller.g.dart';

@riverpod
class LeaderboardController extends _$LeaderboardController {
  @override
  Future<Leaderboard> build() {
    final api = ref.watch(homeApiProvider);
    return seedAndRevalidate(
      cached: api.readCachedLeaderboard(),
      fetch: api.getLeaderboard,
      onRevalidated: (v) => state = AsyncData(v),
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeApiProvider).getLeaderboard());
  }
}
