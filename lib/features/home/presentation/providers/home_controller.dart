import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/stale_while_revalidate.dart';
import '../../data/home_api.dart';
import '../../data/models/home_screen.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeScreenData> build() {
    final api = ref.watch(homeApiProvider);
    return seedAndRevalidate(
      cached: api.readCachedHomeScreen(),
      fetch: api.getHomeScreen,
      onRevalidated: (v) => state = AsyncData(v),
    );
  }

  /// Deliberately doesn't set an intermediate loading state — the old data
  /// stays on screen until the new data (or an error) arrives, per
  /// `uiuxrules.md` §5's pull-to-refresh rule ("keep existing content
  /// visible... never replace the entire list with a spinner").
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeApiProvider).getHomeScreen());
  }
}
