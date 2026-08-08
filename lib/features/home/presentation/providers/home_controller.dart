import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/home_api.dart';
import '../../data/models/home_screen.dart';

part 'home_controller.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  Future<HomeScreenData> build() {
    return ref.watch(homeApiProvider).getHomeScreen();
  }

  /// Deliberately doesn't set an intermediate loading state — the old data
  /// stays on screen until the new data (or an error) arrives, per
  /// `uiuxrules.md` §5's pull-to-refresh rule ("keep existing content
  /// visible... never replace the entire list with a spinner").
  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(homeApiProvider).getHomeScreen());
  }
}
