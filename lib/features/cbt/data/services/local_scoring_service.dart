import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/exam_type_model.dart';
import '../models/question_model.dart';

part 'local_scoring_service.g.dart';

class SubjectScoreBreakdown {
  SubjectScoreBreakdown({required this.subjectId, required this.maxScore});

  final int subjectId;
  final num maxScore;
  int total = 0;
  int correct = 0;
  int wrong = 0;
  int skipped = 0;
  num score = 0;
  num scorePercent = 0;

  Map<String, dynamic> toJson() => {
    'subject_id': subjectId,
    'total': total,
    'correct': correct,
    'wrong': wrong,
    'skipped': skipped,
    'score': score,
    'max_score': maxScore,
    'score_percent': scorePercent,
  };
}

class LocalScoreResult {
  const LocalScoreResult({
    required this.totalQuestions,
    required this.attempted,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.maxScore,
    required this.scorePercent,
    required this.subjectBreakdown,
    required this.pendingAiGradingCount,
  });

  final int totalQuestions;
  final int attempted;
  final int correct;
  final int wrong;
  final int skipped;
  final num score;
  final num maxScore;
  final num scorePercent;
  final List<SubjectScoreBreakdown> subjectBreakdown;

  /// Theory/practical answers can't be AI-graded offline (needs Groq), so
  /// they're only counted as "attempted" here — the real score for them is
  /// applied server-side once `OfflineQueueService` flushes this session and
  /// `ScoringService::score()` runs for real. This is a preview, not final.
  final int pendingAiGradingCount;
}

/// Offline, client-side port of `ScoringService::score()` — used to show an
/// instant result screen right after submit, before the session has even
/// synced. Matches the backend's per-question point-share formula exactly
/// for objective questions; theory/practical questions are recorded as
/// attempted-but-ungraded pending real sync (see [LocalScoreResult]).
class LocalScoringService {
  LocalScoreResult score({
    required ExamTypeModel examType,
    required Map<int, String?> answers,
    required List<int> subjectIds,
    required Map<int, QuestionModel> questionsById,
  }) {
    final subjectBreakdown = <int, SubjectScoreBreakdown>{
      for (final sid in subjectIds) sid: SubjectScoreBreakdown(subjectId: sid, maxScore: examType.maxScorePerSubject),
    };

    final totalPerSubject = <int, int>{};
    for (final q in questionsById.values) {
      totalPerSubject[q.subjectId] = (totalPerSubject[q.subjectId] ?? 0) + 1;
    }

    var totalCorrect = 0;
    var totalWrong = 0;
    var totalSkipped = 0;
    var pendingAi = 0;

    answers.forEach((questionId, userAnswer) {
      final question = questionsById[questionId];
      if (question == null) return;
      final sb = subjectBreakdown[question.subjectId];
      if (sb == null) return;

      sb.total++;
      final questionsInSubject = totalPerSubject[question.subjectId] ?? 0;
      final pointsPerQuestion = questionsInSubject > 0 ? examType.maxScorePerSubject / questionsInSubject : 0.0;

      if (question.isObjective) {
        if (userAnswer == null || userAnswer.isEmpty) {
          sb.skipped++;
          totalSkipped++;
        } else if (userAnswer.toLowerCase() == (question.correctOption ?? '').toLowerCase()) {
          sb.correct++;
          sb.score += pointsPerQuestion;
          totalCorrect++;
        } else {
          sb.wrong++;
          totalWrong++;
        }
      } else {
        if (userAnswer != null && userAnswer.isNotEmpty) {
          sb.correct++;
          totalCorrect++;
          pendingAi++;
        } else {
          sb.skipped++;
          totalSkipped++;
        }
      }
    });

    num totalScore = 0;
    num totalMaxScore = 0;
    for (final sb in subjectBreakdown.values) {
      sb.scorePercent = sb.maxScore > 0 ? _round2((sb.score / sb.maxScore) * 100) : 0;
      totalScore += sb.score;
      totalMaxScore += sb.maxScore;
    }

    final totalQuestions = questionsById.length;
    final attempted = totalCorrect + totalWrong;

    num finalMax;
    num scorePercent;
    if (examType.hasAggregateMax && examType.aggregateMaxScore != null) {
      finalMax = examType.aggregateMaxScore!;
      scorePercent = finalMax > 0 ? _round2((totalScore / finalMax) * 100) : 0;
    } else {
      final subjectCount = subjectBreakdown.length;
      final avgPercent = subjectCount > 0
          ? subjectBreakdown.values.map((s) => s.scorePercent).reduce((a, b) => a + b) / subjectCount
          : 0.0;
      finalMax = totalMaxScore;
      scorePercent = _round2(avgPercent);
    }

    return LocalScoreResult(
      totalQuestions: totalQuestions,
      attempted: attempted,
      correct: totalCorrect,
      wrong: totalWrong,
      skipped: totalSkipped,
      score: _round2(totalScore),
      maxScore: _round2(finalMax),
      scorePercent: scorePercent,
      subjectBreakdown: subjectBreakdown.values.toList(),
      pendingAiGradingCount: pendingAi,
    );
  }

  num _round2(num value) => num.parse(value.toStringAsFixed(2));
}

@Riverpod(keepAlive: true)
LocalScoringService localScoringService(LocalScoringServiceRef ref) => LocalScoringService();
