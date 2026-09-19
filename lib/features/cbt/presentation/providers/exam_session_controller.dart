import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../data/cbt_api.dart';
import '../../data/models/exam_result_data.dart';
import '../../data/models/exam_type_model.dart';
import '../../data/models/offline_session_model.dart';
import '../../data/models/question_model.dart';
import '../../data/services/cbt_sync_service.dart';
import '../../data/services/local_scoring_service.dart';
import '../../data/services/offline_question_builder.dart';
import '../../data/services/offline_queue_service.dart';
import 'pending_exam_configs.dart';

part 'exam_session_controller.g.dart';

class ExamSessionState {
  const ExamSessionState({
    required this.sessionUuid,
    required this.examType,
    required this.mode,
    required this.isOnlineSession,
    required this.subjectIds,
    required this.questionsBySubject,
    required this.orderedQuestions,
    required this.answers,
    required this.bookmarkedIds,
    required this.remainingSeconds,
    required this.currentIndex,
    required this.startedAt,
    required this.optionOrders,
    this.result,
  });

  final String sessionUuid;
  final ExamTypeModel examType;
  final String mode;
  final bool isOnlineSession;
  final List<int> subjectIds;
  final Map<int, List<QuestionModel>> questionsBySubject;
  final List<QuestionModel> orderedQuestions;
  final Map<int, String?> answers;
  final Set<int> bookmarkedIds;
  final int? remainingSeconds;
  final int currentIndex;
  final int startedAt;

  /// questionId -> shuffled option-key order, pinned for the lifetime of
  /// this attempt (see `OfflineSessionModel.optionOrders`).
  final Map<int, List<String>> optionOrders;
  final ExamResultData? result;

  /// A question's options in their shuffled display order — falls back to
  /// natural order if it's somehow missing an entry (shouldn't happen for
  /// sessions built after this feature shipped, e.g. an in-progress session
  /// resumed after an app update).
  List<OptionModel> orderedOptionsFor(QuestionModel question) {
    final order = optionOrders[question.id];
    if (order == null) return question.options;
    final byKey = {for (final o in question.options) o.key: o};
    return [for (final key in order) if (byKey[key] != null) byKey[key]!];
  }

  QuestionModel get currentQuestion => orderedQuestions[currentIndex];
  bool get isTimed => remainingSeconds != null;
  int get totalQuestions => orderedQuestions.length;
  int get answeredCount => answers.values.where((v) => v != null && v.isNotEmpty).length;

  /// Index of the first question belonging to each subject, in the exact
  /// order subjects appear in [subjectIds] — powers the exam screen's
  /// "jump to subject" navigation.
  Map<int, int> get subjectStartIndexes {
    final map = <int, int>{};
    var index = 0;
    for (final subjectId in subjectIds) {
      map[subjectId] = index;
      index += questionsBySubject[subjectId]?.length ?? 0;
    }
    return map;
  }

  ExamSessionState copyWith({
    Map<int, String?>? answers,
    Set<int>? bookmarkedIds,
    int? remainingSeconds,
    bool clearRemaining = false,
    int? currentIndex,
    ExamResultData? result,
  }) {
    return ExamSessionState(
      sessionUuid: sessionUuid,
      examType: examType,
      mode: mode,
      isOnlineSession: isOnlineSession,
      subjectIds: subjectIds,
      questionsBySubject: questionsBySubject,
      orderedQuestions: orderedQuestions,
      answers: answers ?? this.answers,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      remainingSeconds: clearRemaining ? null : (remainingSeconds ?? this.remainingSeconds),
      currentIndex: currentIndex ?? this.currentIndex,
      startedAt: startedAt,
      optionOrders: optionOrders,
      result: result ?? this.result,
    );
  }
}

/// Drives a single exam attempt end-to-end: builds the question set
/// (online via `startSession`, falling back to `OfflineQuestionBuilder`
/// on any failure), ticks the timer, autosaves every answer to Hive so
/// nothing is ever lost, and scores on submit (authoritative online, a
/// local preview offline — queued for the real score once synced).
/// `keepAlive: true` (per session key) so the Exam → Result → Review
/// navigation chain can all read the same state without a disposal race —
/// this is an autoDispose-by-default family otherwise, and a stray frame
/// with zero watchers between `pushReplacement` calls could tear the
/// in-progress session down before the result screen ever reads it.
@Riverpod(keepAlive: true)
class ExamSessionController extends _$ExamSessionController {
  Timer? _timer;
  final _random = Random();

  @override
  Future<ExamSessionState> build(String sessionKey) async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    // Resume: `sessionKey` is the exam's `offlineUuid` whenever the caller
    // navigated here from an existing in-progress session (see
    // `ExamTypesScreen`'s "Continue exam" affordance) rather than a fresh
    // session-setup launch — those two cases share this one route/provider
    // so an app restart mid-exam always lands back in the same place.
    final existingSession = HiveSetup.offlineSessionsBox.get(sessionKey);
    if (existingSession != null && existingSession.status == SessionStatus.inProgress) {
      return _resume(existingSession);
    }

    final configs = ref.read(pendingExamConfigsProvider.notifier);
    final launch = configs.peek(sessionKey);
    if (launch == null) {
      throw StateError('No pending exam config for this session — it may have already been started.');
    }
    // Deferred a tick: Riverpod forbids mutating another provider's state
    // synchronously while this provider is still building (peek above is
    // read-only for that reason) — see pending_exam_configs.dart.
    Future.microtask(() => configs.remove(sessionKey));

    final examType = launch.examType;
    final config = launch.sessionConfig;
    final api = ref.read(cbtApiProvider);
    final builder = ref.read(offlineQuestionBuilderProvider);
    final syncService = ref.read(cbtSyncServiceProvider);

    Map<int, List<QuestionModel>> questionsBySubject;
    var isOnlineSession = false;
    String sessionUuid;

    try {
      final response = await api.startSession({
        'exam_type_id': config.examTypeId,
        'mode': config.mode,
        'subject_ids': config.subjectIds,
        'question_type': config.questionType,
        if (config.year != null) 'year': config.year,
        if (config.topicId != null) 'topic_id': config.topicId,
        if (config.questionCount != null) 'question_count': config.questionCount,
        if (launch.durationMinutes != null) 'duration_minutes': launch.durationMinutes,
        'include_comprehension': config.includeComprehension,
        'include_register': config.includeRegister,
        'include_literature': config.includeLiterature,
      });

      sessionUuid = response['session_uuid'] as String;
      isOnlineSession = true;

      final rawBySubject = response['questions_by_subject'] as Map<String, dynamic>? ?? {};
      questionsBySubject = {
        for (final entry in rawBySubject.entries)
          int.parse(entry.key): (entry.value as List<dynamic>)
              .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
              .toList(),
      };

      final questionsBox = HiveSetup.questionsBox;
      for (final qs in questionsBySubject.values) {
        for (final q in qs) {
          await questionsBox.put(q.id, q);
        }
      }

      final isPaid = response['is_paid'] as bool? ?? false;
      await syncService.cachePaidAccess(examType.id, isPaid);
    } catch (_) {
      isOnlineSession = false;
      sessionUuid = const Uuid().v4();
      questionsBySubject = builder.build(config);
    }

    final orderedQuestions = <QuestionModel>[
      for (final subjectId in config.subjectIds) ...?questionsBySubject[subjectId],
    ];

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final remainingSeconds = launch.durationMinutes != null ? launch.durationMinutes! * 60 : null;

    // Shuffle each question's option *order* once, here, for the lifetime of
    // this attempt — grading always compares by the option's stable key
    // (`answer()` stores `option.key`, never a position), so reordering how
    // they're displayed can't break correctness. Pinned to Hive immediately
    // so a resumed session shows options in the exact same order.
    final optionOrders = <int, List<String>>{
      for (final q in orderedQuestions) q.id: (q.options.map((o) => o.key).toList()..shuffle(_random)),
    };

    final sessionModel = OfflineSessionModel(
      offlineUuid: sessionUuid,
      examTypeId: examType.id,
      mode: config.mode,
      subjectIds: config.subjectIds,
      topicIds: config.topicId != null ? [config.topicId!] : const [],
      year: config.year,
      questionIds: orderedQuestions.map((q) => q.id).toList(),
      answers: const {},
      bookmarkedQuestionIds: const [],
      durationMinutes: launch.durationMinutes,
      startedAt: now,
      remainingSeconds: remainingSeconds,
      status: SessionStatus.inProgress,
      isSynced: isOnlineSession,
      currentIndex: 0,
      optionOrders: optionOrders,
    );
    await HiveSetup.offlineSessionsBox.put(sessionUuid, sessionModel);

    if (remainingSeconds != null) {
      _startTimer();
    }

    return ExamSessionState(
      sessionUuid: sessionUuid,
      examType: examType,
      mode: config.mode,
      isOnlineSession: isOnlineSession,
      subjectIds: config.subjectIds,
      questionsBySubject: questionsBySubject,
      orderedQuestions: orderedQuestions,
      answers: const {},
      bookmarkedIds: const {},
      remainingSeconds: remainingSeconds,
      currentIndex: 0,
      startedAt: now,
      optionOrders: optionOrders,
    );
  }

  /// Rebuilds state directly from a persisted in-progress session — no
  /// backend call, no fresh shuffle, no pending-config lookup. Every piece
  /// (question order, option order, answers, bookmarks, remaining time,
  /// current position) comes straight from Hive.
  Future<ExamSessionState> _resume(OfflineSessionModel existing) async {
    final examType = HiveSetup.examTypesBox.get(existing.examTypeId);
    if (examType == null) {
      throw StateError('Exam type ${existing.examTypeId} is not synced locally — cannot resume this session.');
    }

    final questionsBox = HiveSetup.questionsBox;
    final orderedQuestions = <QuestionModel>[
      for (final id in existing.questionIds)
        if (questionsBox.get(id) case final q?) q,
    ];

    // A session with no resolvable questions (empty questionIds, or every
    // question has since been evicted from Hive) can't be resumed —
    // ExamSessionState.currentQuestion indexes into this list. The entry
    // point (ExamTypesScreen._findResumableSession) already filters these
    // out, but guard here too since nothing stops a stale route/deep-link
    // from hitting this provider directly with an old session key.
    if (orderedQuestions.isEmpty) {
      throw StateError('This saved exam session has no questions left to resume.');
    }

    final questionsBySubject = <int, List<QuestionModel>>{};
    for (final q in orderedQuestions) {
      (questionsBySubject[q.subjectId] ??= []).add(q);
    }

    if ((existing.remainingSeconds ?? 0) > 0) {
      _startTimer();
    }

    return ExamSessionState(
      sessionUuid: existing.offlineUuid,
      examType: examType,
      mode: existing.mode,
      isOnlineSession: existing.isSynced,
      subjectIds: existing.subjectIds,
      questionsBySubject: questionsBySubject,
      orderedQuestions: orderedQuestions,
      answers: {for (final entry in existing.answers.entries) entry.key: entry.value},
      bookmarkedIds: existing.bookmarkedQuestionIds.toSet(),
      remainingSeconds: existing.remainingSeconds,
      currentIndex: orderedQuestions.isEmpty ? 0 : existing.currentIndex.clamp(0, orderedQuestions.length - 1),
      startedAt: existing.startedAt,
      optionOrders: existing.optionOrders,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final current = state.valueOrNull;
    if (current == null || current.remainingSeconds == null) return;
    final next = current.remainingSeconds! - 1;

    if (next <= 0) {
      _timer?.cancel();
      state = AsyncData(current.copyWith(remainingSeconds: 0));
      submit();
      return;
    }

    state = AsyncData(current.copyWith(remainingSeconds: next));
    if (next % 15 == 0) unawaited(_persistSnapshot());
  }

  void answer(int questionId, String? value) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(answers: {...current.answers, questionId: value}));
    unawaited(_persistSnapshot());
  }

  void toggleBookmark(int questionId) {
    final current = state.valueOrNull;
    if (current == null) return;
    final bookmarks = {...current.bookmarkedIds};
    final adding = !bookmarks.contains(questionId);
    adding ? bookmarks.add(questionId) : bookmarks.remove(questionId);
    state = AsyncData(current.copyWith(bookmarkedIds: bookmarks));
    unawaited(_persistSnapshot());
    unawaited(_syncBookmark(questionId, adding));
  }

  Future<void> _syncBookmark(int questionId, bool adding) async {
    try {
      await ref.read(cbtApiProvider).toggleBookmark(questionId);
    } catch (_) {
      await ref.read(offlineQueueServiceProvider).enqueueBookmarkToggle(questionId, bookmarked: adding);
    }
  }

  void jumpTo(int index) {
    final current = state.valueOrNull;
    if (current == null || index < 0 || index >= current.orderedQuestions.length) return;
    state = AsyncData(current.copyWith(currentIndex: index));
    unawaited(_persistSnapshot());
  }

  void next() {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.currentIndex < current.orderedQuestions.length - 1) jumpTo(current.currentIndex + 1);
  }

  void previous() {
    final current = state.valueOrNull;
    if (current == null) return;
    if (current.currentIndex > 0) jumpTo(current.currentIndex - 1);
  }

  Future<void> _persistSnapshot() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final model = HiveSetup.offlineSessionsBox.get(current.sessionUuid);
    if (model == null) return;
    model.answers = {
      for (final entry in current.answers.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
    model.bookmarkedQuestionIds = current.bookmarkedIds.toList();
    model.remainingSeconds = current.remainingSeconds;
    model.currentIndex = current.currentIndex;
    await model.save();
  }

  Future<ExamResultData> submit() async {
    _timer?.cancel();
    final current = state.valueOrNull;
    if (current == null) throw StateError('No active exam session.');
    if (current.result != null) return current.result!;

    final model = HiveSetup.offlineSessionsBox.get(current.sessionUuid);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeSpentSeconds = now - current.startedAt;

    String subjectName(int id) => HiveSetup.subjectsBox.get(id)?.name ?? 'Subject $id';

    ExamResultData result;
    var needsQueue = !current.isOnlineSession;

    if (current.isOnlineSession) {
      try {
        final response = await ref
            .read(cbtApiProvider)
            .submitSession(
              uuid: current.sessionUuid,
              answers: current.answers.map((k, v) => MapEntry(k.toString(), v)),
              timeSpentSeconds: timeSpentSeconds,
              bookmarkedIds: current.bookmarkedIds.toList(),
            );
        result = ExamResultData.fromApiJson(response, subjectName);
      } catch (_) {
        result = _buildLocalResult(current, timeSpentSeconds, subjectName);
        needsQueue = true;
      }
    } else {
      result = _buildLocalResult(current, timeSpentSeconds, subjectName);
    }

    if (model != null) {
      model
        ..answers = {
          for (final entry in current.answers.entries)
            if (entry.value != null) entry.key: entry.value!,
        }
        ..bookmarkedQuestionIds = current.bookmarkedIds.toList()
        ..status = SessionStatus.submitted
        ..submittedAt = now
        ..score = result.score
        ..totalMaxScore = result.maxScore
        ..subjectScores = {for (final s in result.subjectBreakdown) s.subjectId: s.score};
      await model.save();

      if (needsQueue) {
        await ref.read(offlineQueueServiceProvider).enqueueSessionSubmission(model);
      }
    }

    state = AsyncData(current.copyWith(result: result));
    return result;
  }

  ExamResultData _buildLocalResult(ExamSessionState current, int timeSpentSeconds, String Function(int) subjectName) {
    final questionsById = {for (final q in current.orderedQuestions) q.id: q};
    final local = ref
        .read(localScoringServiceProvider)
        .score(
          examType: current.examType,
          answers: current.answers,
          subjectIds: current.subjectIds,
          questionsById: questionsById,
        );
    return ExamResultData.fromLocalScore(
      local,
      sessionUuid: current.sessionUuid,
      mode: current.mode,
      timeSpentSeconds: timeSpentSeconds,
      subjectName: subjectName,
    );
  }
}
