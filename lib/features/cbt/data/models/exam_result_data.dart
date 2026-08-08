import '../services/local_scoring_service.dart';

class SubjectResultBreakdown {
  const SubjectResultBreakdown({
    required this.subjectId,
    required this.subjectName,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.maxScore,
    required this.scorePercent,
  });

  final int subjectId;
  final String subjectName;
  final int total;
  final int correct;
  final int wrong;
  final int skipped;
  final num score;
  final num maxScore;
  final num scorePercent;

  factory SubjectResultBreakdown.fromJson(Map<String, dynamic> json, String Function(int) subjectName) {
    final subjectId = json['subject_id'] as int;
    return SubjectResultBreakdown(
      subjectId: subjectId,
      subjectName: subjectName(subjectId),
      total: json['total'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      wrong: json['wrong'] as int? ?? 0,
      skipped: json['skipped'] as int? ?? 0,
      score: json['score'] as num? ?? 0,
      maxScore: json['max_score'] as num? ?? 0,
      scorePercent: json['score_percent'] as num? ?? 0,
    );
  }

  factory SubjectResultBreakdown.fromLocal(SubjectScoreBreakdown b, String Function(int) subjectName) {
    return SubjectResultBreakdown(
      subjectId: b.subjectId,
      subjectName: subjectName(b.subjectId),
      total: b.total,
      correct: b.correct,
      wrong: b.wrong,
      skipped: b.skipped,
      score: b.score,
      maxScore: b.maxScore,
      scorePercent: b.scorePercent,
    );
  }
}

/// Unified result shape for both an authoritative online result
/// (`CBTController::formatResult()`) and a local offline preview
/// (`LocalScoringService`) — the result/review screens don't need to know
/// which one produced it, only [isOfflinePreview] to show a "will update
/// once synced" note for theory/practical answers.
class ExamResultData {
  const ExamResultData({
    required this.sessionUuid,
    required this.mode,
    required this.totalQuestions,
    required this.attempted,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.score,
    required this.maxScore,
    required this.scorePercent,
    required this.timeSpentSeconds,
    required this.subjectBreakdown,
    required this.isOfflinePreview,
    this.pendingAiGradingCount = 0,
  });

  final String sessionUuid;
  final String mode;
  final int totalQuestions;
  final int attempted;
  final int correct;
  final int wrong;
  final int skipped;
  final num score;
  final num maxScore;
  final num scorePercent;
  final int timeSpentSeconds;
  final List<SubjectResultBreakdown> subjectBreakdown;
  final bool isOfflinePreview;
  final int pendingAiGradingCount;

  factory ExamResultData.fromApiJson(Map<String, dynamic> json, String Function(int) subjectName) {
    final breakdown = (json['subject_breakdown'] as List<dynamic>? ?? [])
        .map((e) => SubjectResultBreakdown.fromJson(e as Map<String, dynamic>, subjectName))
        .toList();
    return ExamResultData(
      sessionUuid: json['session_uuid'] as String? ?? '',
      mode: json['mode'] as String? ?? '',
      totalQuestions: json['total_questions'] as int? ?? 0,
      attempted: json['attempted'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      wrong: json['wrong'] as int? ?? 0,
      skipped: json['skipped'] as int? ?? 0,
      score: json['score'] as num? ?? 0,
      maxScore: json['max_score'] as num? ?? 0,
      scorePercent: json['score_percent'] as num? ?? 0,
      timeSpentSeconds: json['time_spent_seconds'] as int? ?? 0,
      subjectBreakdown: breakdown,
      isOfflinePreview: false,
    );
  }

  factory ExamResultData.fromLocalScore(
    LocalScoreResult local, {
    required String sessionUuid,
    required String mode,
    required int timeSpentSeconds,
    required String Function(int) subjectName,
  }) {
    return ExamResultData(
      sessionUuid: sessionUuid,
      mode: mode,
      totalQuestions: local.totalQuestions,
      attempted: local.attempted,
      correct: local.correct,
      wrong: local.wrong,
      skipped: local.skipped,
      score: local.score,
      maxScore: local.maxScore,
      scorePercent: local.scorePercent,
      timeSpentSeconds: timeSpentSeconds,
      subjectBreakdown: local.subjectBreakdown.map((b) => SubjectResultBreakdown.fromLocal(b, subjectName)).toList(),
      isOfflinePreview: true,
      pendingAiGradingCount: local.pendingAiGradingCount,
    );
  }
}
