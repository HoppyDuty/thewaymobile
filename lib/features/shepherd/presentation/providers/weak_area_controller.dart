import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/weak_area_models.dart';
import '../../data/shepherd_api.dart';

part 'weak_area_controller.g.dart';

/// No auto-fetch on build — analysis is user-triggered (it costs an AI
/// call against a 5/day quota with a 6h regen cooldown), so this starts
/// empty until [analyze] is called.
@riverpod
class WeakAreaController extends _$WeakAreaController {
  @override
  Future<WeakAreaAnalysis?> build() async => null;

  Future<void> analyze({int? examTypeId}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(shepherdApiProvider).analyzeWeakAreas(examTypeId: examTypeId));
  }
}
