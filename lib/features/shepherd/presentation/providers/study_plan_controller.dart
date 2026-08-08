import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/study_plan_models.dart';
import '../../data/shepherd_api.dart';

part 'study_plan_controller.g.dart';

@riverpod
class StudyPlanController extends _$StudyPlanController {
  @override
  Future<StudyPlan?> build() {
    return ref.watch(shepherdApiProvider).getActiveStudyPlan();
  }

  Future<void> generate({
    required DateTime examDate,
    int? examTypeId,
    List<String> focusSubjects = const [],
    String? extraContext,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(shepherdApiProvider)
          .generateStudyPlan(
            examDate: examDate,
            examTypeId: examTypeId,
            focusSubjects: focusSubjects,
            extraContext: extraContext,
          ),
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
