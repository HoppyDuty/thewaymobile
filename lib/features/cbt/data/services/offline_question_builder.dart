import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';
import '../models/exam_type_model.dart';
import '../models/offline_session_model.dart';
import '../models/question_model.dart';
import '../models/question_passage_group_model.dart';
import 'cbt_sync_service.dart';

part 'offline_question_builder.g.dart';

/// Everything needed to assemble a question set, mirroring the `$config`
/// array `QuestionBuilderService::build()` takes on the backend.
class SessionConfig {
  const SessionConfig({
    required this.examTypeId,
    required this.mode,
    required this.subjectIds,
    this.questionType = 'objective',
    this.year,
    this.topicId,
    this.questionCount,
    this.includeComprehension = false,
    this.includeRegister = false,
    this.includeLiterature = false,
  });

  final int examTypeId;
  final String mode;
  final List<int> subjectIds;
  final String questionType;
  final int? year;
  final int? topicId;
  final int? questionCount;
  final bool includeComprehension;
  final bool includeRegister;
  final bool includeLiterature;
}

/// A local, offline port of `QuestionBuilderService` — reads only from Hive
/// (populated by `CbtSyncService`) so a session can be built with zero
/// connectivity. Rule-for-rule match with the backend:
/// - Free users: first 5 questions per subject, deterministic (ordered by id)
/// - Paid users: full pool; shuffled unless the mode calls for stable order
/// - English block ordering: comprehension → register → literature → normal
/// - Register questions stay chronological (`passageOrder`)
class OfflineQuestionBuilder {
  OfflineQuestionBuilder(this._sync);

  final CbtSyncService _sync;
  static const _freeLimit = 5;
  final _random = Random();

  Map<int, List<QuestionModel>> build(SessionConfig config) {
    final examType = HiveSetup.examTypesBox.get(config.examTypeId);
    if (examType == null) {
      throw StateError('Exam type ${config.examTypeId} is not synced locally yet.');
    }
    final isPaid = _sync.getPaidAccess(config.examTypeId);

    final result = <int, List<QuestionModel>>{};
    for (final subjectId in config.subjectIds) {
      final subject = HiveSetup.subjectsBox.get(subjectId);
      final isEnglish = subject?.isEnglish ?? false;
      result[subjectId] = _buildSubjectQuestions(examType, subjectId, isEnglish, isPaid, config);
    }
    return result;
  }

  List<QuestionModel> _buildSubjectQuestions(
    ExamTypeModel examType,
    int subjectId,
    bool isEnglish,
    bool isPaid,
    SessionConfig config,
  ) {
    final limit = _resolveLimit(examType, config.mode, isEnglish, config);

    if (!isPaid) {
      return _buildFreeQuestions(examType.id, subjectId, config.questionType);
    }

    if (isEnglish && config.mode != ExamMode.topical) {
      return _buildEnglishBlock(
        examTypeId: examType.id,
        subjectId: subjectId,
        totalLimit: limit,
        includeComprehension: config.includeComprehension,
        includeRegister: config.includeRegister,
        includeLiterature: config.includeLiterature,
        year: config.year,
      );
    }

    return _buildNormalQuestions(
      examTypeId: examType.id,
      subjectId: subjectId,
      limit: limit,
      questionType: config.questionType,
      year: config.year,
      topicId: config.topicId,
      shuffle: const [ExamMode.standard, ExamMode.yearly, ExamMode.practice].contains(config.mode),
    );
  }

  List<QuestionModel> _buildFreeQuestions(int examTypeId, int subjectId, String questionType) {
    final qs = _allQuestions
        .where((q) => q.examTypeId == examTypeId && q.subjectId == subjectId && q.specialType == 'normal')
        .where((q) => questionType == 'all' || q.questionType == questionType)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return qs.take(_freeLimit).toList();
  }

  List<QuestionModel> _buildEnglishBlock({
    required int examTypeId,
    required int subjectId,
    required int totalLimit,
    required bool includeComprehension,
    required bool includeRegister,
    required bool includeLiterature,
    int? year,
  }) {
    final questions = <QuestionModel>[];
    var remaining = totalLimit;

    if (includeComprehension && remaining > 0) {
      final passage = _getOnePassage(examTypeId, subjectId, 'comprehension', year);
      if (passage != null) {
        final qs = _questionsForPassage(passage.id).take(5).toList();
        questions.addAll(qs);
        remaining -= qs.length;
      }
    }

    if (includeRegister && remaining > 0) {
      final passage = _getOnePassage(examTypeId, subjectId, 'register', year);
      if (passage != null) {
        final qs = _questionsForPassage(passage.id).take(10).toList();
        questions.addAll(qs);
        remaining -= qs.length;
      }
    }

    if (includeLiterature && remaining > 0) {
      final passage = _getOnePassage(examTypeId, subjectId, 'literature', year);
      if (passage != null) {
        final qs = _questionsForPassage(passage.id).take(5).toList();
        questions.addAll(qs);
        remaining -= qs.length;
      }
    }

    if (remaining > 0) {
      final normalQs = _allQuestions
          .where(
            (q) =>
                q.examTypeId == examTypeId &&
                q.subjectId == subjectId &&
                q.questionType == 'objective' &&
                q.specialType == 'normal',
          )
          .where((q) => year == null || q.year == year)
          .toList()
        ..shuffle(_random);
      questions.addAll(normalQs.take(remaining));
    }

    return questions;
  }

  List<QuestionModel> _buildNormalQuestions({
    required int examTypeId,
    required int subjectId,
    required int limit,
    required String questionType,
    int? year,
    int? topicId,
    required bool shuffle,
  }) {
    final qs = _allQuestions
        .where((q) => q.examTypeId == examTypeId && q.subjectId == subjectId && q.specialType == 'normal')
        .where((q) => questionType == 'all' || q.questionType == questionType)
        .where((q) => year == null || q.year == year)
        .where((q) => topicId == null || q.topicId == topicId)
        .toList();

    if (shuffle) {
      qs.shuffle(_random);
    } else {
      qs.sort((a, b) => a.id.compareTo(b.id));
    }

    return qs.take(limit).toList();
  }

  int _resolveLimit(ExamTypeModel examType, String mode, bool isEnglish, SessionConfig config) {
    switch (mode) {
      case ExamMode.standard:
      case ExamMode.yearly:
        return isEnglish ? examType.englishQuestionCount : examType.otherSubjectQuestionCount;
      case ExamMode.study:
      case ExamMode.practice:
      case ExamMode.topical:
        return (config.questionCount ?? 20).clamp(5, 100);
      default:
        return 20;
    }
  }

  Iterable<QuestionModel> _questionsForPassage(int passageGroupId) {
    final qs = _allQuestions.where((q) => q.passageGroupId == passageGroupId).toList()
      ..sort((a, b) => (a.passageOrder ?? 0).compareTo(b.passageOrder ?? 0));
    return qs;
  }

  QuestionPassageGroupModel? _getOnePassage(int examTypeId, int subjectId, String type, int? year) {
    final candidates = HiveSetup.passageGroupsBox.values
        .where((pg) => pg.examTypeId == examTypeId && pg.subjectId == subjectId && pg.type == type)
        .where((pg) => year == null || pg.year == year)
        .toList();
    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  Iterable<QuestionModel> get _allQuestions => HiveSetup.questionsBox.values;
}

@Riverpod(keepAlive: true)
OfflineQuestionBuilder offlineQuestionBuilder(OfflineQuestionBuilderRef ref) {
  return OfflineQuestionBuilder(ref.watch(cbtSyncServiceProvider));
}
