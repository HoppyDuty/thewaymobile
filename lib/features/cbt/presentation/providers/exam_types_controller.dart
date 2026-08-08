import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/services/cbt_sync_service.dart';

part 'exam_types_controller.g.dart';

/// Exam types shown on the CBT tab / topical-study picker. Always reads
/// from Hive first (instant, offline-safe) and syncs in the background
/// the first time the box is empty — once synced, this list survives
/// indefinitely offline (no TTL), matching the "2+ months offline" CBT
/// requirement.
@riverpod
class ExamTypesController extends _$ExamTypesController {
  @override
  Future<List<ExamTypeModel>> build() async {
    final box = HiveSetup.examTypesBox;
    if (box.isEmpty) {
      try {
        await ref.read(cbtSyncServiceProvider).syncExamTypesAndSubjects();
      } catch (_) {
        // No connectivity yet and nothing cached — surface an empty list;
        // the screen shows an offline-empty state rather than an error.
      }
    }
    final list = box.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  Future<void> refresh() async {
    await ref.read(cbtSyncServiceProvider).syncExamTypesAndSubjects();
    ref.invalidateSelf();
    await future;
  }
}
