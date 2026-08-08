import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';
import '../cbt_api.dart';
import '../models/delta_checkpoint_model.dart';
import '../models/exam_type_model.dart';
import '../models/question_model.dart';
import '../models/question_passage_group_model.dart';
import '../models/subject_model.dart';

part 'cbt_sync_service.g.dart';

/// Pulls the CBT question bank into Hive so the exam engine never needs a
/// live connection once synced — matches `phase4.md`'s prescribed
/// `CbtSyncService` (exam-types/subjects full sync + per-exam-type
/// delta-checkpointed question sync). Everything it writes lives in Hive
/// with no TTL, which is what satisfies "offline for 2+ months."
class CbtSyncService {
  CbtSyncService(this._api);

  final CbtApi _api;

  static const _paidAccessKey = 'cbt_paid_access';

  Future<void> syncExamTypesAndSubjects() async {
    final examTypesJson = await _api.getExamTypes();
    final examTypesBox = HiveSetup.examTypesBox;
    for (final json in examTypesJson) {
      final model = ExamTypeModel.fromJson(json as Map<String, dynamic>);
      await examTypesBox.put(model.id, model);
    }

    final subjectsJson = await _api.getSubjects();
    final subjectsBox = HiveSetup.subjectsBox;
    for (final json in subjectsJson) {
      final model = SubjectModel.fromJson(json as Map<String, dynamic>);
      await subjectsBox.put(model.id, model);
    }
  }

  /// Delta-syncs every question page for [examTypeId] since the last
  /// checkpoint, merging active questions/passage groups into Hive and
  /// removing any the backend reports as deleted — mirrors
  /// `CbtDeltaSyncService::getQuestionDelta()` page-by-page exactly.
  Future<void> syncQuestionsForExamType(int examTypeId) async {
    final checkpointBox = HiveSetup.deltaCheckpointsBox;
    final checkpoint = checkpointBox.get(examTypeId);
    final since = checkpoint != null
        ? DateTime.fromMillisecondsSinceEpoch(checkpoint.lastSyncedAt * 1000, isUtc: true).toIso8601String()
        : null;

    final questionsBox = HiveSetup.questionsBox;
    final passageGroupsBox = HiveSetup.passageGroupsBox;

    var page = 1;
    var hasMore = true;
    var total = checkpoint?.totalQuestions ?? 0;
    String? checksum = checkpoint?.checksum;
    String? nextSince;
    var isPaid = false;

    while (hasMore) {
      final delta = await _api.getQuestionDelta(examTypeId: examTypeId, since: since, page: page);

      final questionsJson = delta['questions'] as List<dynamic>? ?? [];
      for (final json in questionsJson) {
        final model = QuestionModel.fromJson(json as Map<String, dynamic>);
        await questionsBox.put(model.id, model);
      }

      final deletedIds = (delta['deleted_ids'] as List<dynamic>? ?? []).cast<int>();
      for (final id in deletedIds) {
        await questionsBox.delete(id);
      }

      final passageGroupsJson = delta['passage_groups'] as List<dynamic>? ?? [];
      for (final json in passageGroupsJson) {
        final model = QuestionPassageGroupModel.fromJson(json as Map<String, dynamic>);
        await passageGroupsBox.put(model.id, model);
      }

      total = delta['total'] as int? ?? total;
      hasMore = delta['has_more'] as bool? ?? false;
      checksum = delta['checksum'] as String? ?? checksum;
      nextSince = delta['next_since'] as String? ?? nextSince;
      isPaid = delta['is_paid'] as bool? ?? isPaid;
      page++;
    }

    await cachePaidAccess(examTypeId, isPaid);

    if (nextSince != null) {
      await checkpointBox.put(
        examTypeId,
        DeltaCheckpointModel(
          examTypeId: examTypeId,
          lastSyncedAt: DateTime.parse(nextSince).millisecondsSinceEpoch ~/ 1000,
          totalQuestions: total,
          checksum: checksum,
        ),
      );
    }
  }

  Future<void> syncAllQuestionBanks() async {
    for (final examType in HiveSetup.examTypesBox.values) {
      await syncQuestionsForExamType(examType.id);
    }
  }

  // ── Paid-access cache ─────────────────────────────────────────────────────
  //
  // `UserExamAccess` lives server-side only; the offline question builder
  // needs a locally-cached flag to decide free-vs-paid limits without a
  // network call, so we snapshot whatever the last online response told us
  // (`questions/delta`'s `is_paid`, or `startSession`'s `is_paid`).

  Future<void> cachePaidAccess(int examTypeId, bool isPaid) async {
    final map = _paidAccessMap;
    map[examTypeId.toString()] = isPaid;
    await HiveSetup.settingsBox.put(_paidAccessKey, map);
  }

  bool getPaidAccess(int examTypeId) => _paidAccessMap[examTypeId.toString()] as bool? ?? false;

  Map<String, dynamic> get _paidAccessMap {
    final raw = HiveSetup.settingsBox.get(_paidAccessKey);
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }
}

@Riverpod(keepAlive: true)
CbtSyncService cbtSyncService(CbtSyncServiceRef ref) {
  return CbtSyncService(ref.watch(cbtApiProvider));
}
