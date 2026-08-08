import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'offline_session_model.g.dart';

/// Exam mode — mirrors the 5 modes described in the CBT rules table
/// (`phase4.md` + `app_flow.md`): each carries different subject-count,
/// timer, year and topic constraints, enforced by `OfflineQuestionBuilder`.
class ExamMode {
  static const standard = 'standard';
  static const yearly = 'yearly';
  static const practice = 'practice';
  static const study = 'study';
  static const topical = 'topical';
}

class SessionStatus {
  static const inProgress = 'in_progress';
  static const submitted = 'submitted';
  static const scored = 'scored';
}

/// A locally-taken (or in-progress) exam session — the offline source of
/// truth for the CBT engine. Lives in Hive for 2+ months (no TTL eviction);
/// synced to the backend opportunistically by `SyncManager`/`OfflineQueueService`
/// once connectivity returns.
@HiveType(typeId: kHiveTypeOfflineSession)
class OfflineSessionModel extends HiveObject {
  OfflineSessionModel({
    required this.offlineUuid,
    this.serverId,
    required this.examTypeId,
    required this.mode,
    this.subjectIds = const [],
    this.topicIds = const [],
    this.year,
    this.questionIds = const [],
    this.answers = const {},
    this.bookmarkedQuestionIds = const [],
    this.durationMinutes,
    required this.startedAt,
    this.submittedAt,
    this.remainingSeconds,
    required this.status,
    this.score,
    this.totalMaxScore,
    this.subjectScores = const {},
    this.isSynced = false,
  });

  /// Client-generated UUID — the durable local identity of this session,
  /// used as the idempotency key when it's later pushed to the backend.
  @HiveField(0)
  final String offlineUuid;

  /// Populated once the backend has accepted this session and assigned it
  /// a real row id.
  @HiveField(1)
  int? serverId;

  @HiveField(2)
  final int examTypeId;

  @HiveField(3)
  final String mode;

  @HiveField(4)
  final List<int> subjectIds;

  /// Only meaningful for [ExamMode.topical].
  @HiveField(5)
  final List<int> topicIds;

  /// Only meaningful for [ExamMode.yearly].
  @HiveField(6)
  final int? year;

  /// The exact, ordered question sequence for this session — built once at
  /// session start by `OfflineQuestionBuilder` and never reshuffled, so a
  /// resumed session always shows questions in the same order.
  @HiveField(7)
  final List<int> questionIds;

  /// questionId -> selected option key ('a'..'e') or free-text answer.
  @HiveField(8)
  Map<int, String> answers;

  @HiveField(9)
  List<int> bookmarkedQuestionIds;

  /// Null for untimed modes (Practice/Study).
  @HiveField(10)
  final int? durationMinutes;

  /// Unix timestamp (seconds).
  @HiveField(11)
  final int startedAt;

  @HiveField(12)
  int? submittedAt;

  /// Ticks down locally while the exam is in progress; persisted on every
  /// autosave so a killed app / dead battery never loses timer state.
  @HiveField(13)
  int? remainingSeconds;

  @HiveField(14)
  String status;

  @HiveField(15)
  num? score;

  @HiveField(16)
  num? totalMaxScore;

  /// subjectId -> raw score for that subject, computed by `LocalScoringService`.
  @HiveField(17)
  Map<int, num> subjectScores;

  @HiveField(18)
  bool isSynced;

  bool get isTimed => durationMinutes != null;

  bool get isSubmitted => status != SessionStatus.inProgress;
}
