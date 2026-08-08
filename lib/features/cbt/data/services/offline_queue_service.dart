import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/hive_setup.dart';
import '../models/offline_session_model.dart';
import '../models/pending_operation_model.dart';

part 'offline_queue_service.g.dart';

/// Durable, Hive-backed queue of not-yet-synced mutations. Survives an app
/// kill — `SyncManager` drains it whenever connectivity returns.
class OfflineQueueService {
  static const _uuid = Uuid();

  Future<void> enqueueSessionSubmission(OfflineSessionModel session) {
    final startedAt = DateTime.fromMillisecondsSinceEpoch(session.startedAt * 1000, isUtc: true);
    final submittedAt = DateTime.fromMillisecondsSinceEpoch(
      (session.submittedAt ?? session.startedAt) * 1000,
      isUtc: true,
    );
    final timeSpentSeconds = session.durationMinutes != null && session.remainingSeconds != null
        ? (session.durationMinutes! * 60 - session.remainingSeconds!).clamp(0, 1 << 31)
        : submittedAt.difference(startedAt).inSeconds;

    return enqueue(PendingOperationType.submitSession, {
      'offline_uuid': session.offlineUuid,
      'exam_type_id': session.examTypeId,
      'mode': session.mode,
      'question_type_filter': 'objective',
      'year_filter': session.year,
      'subject_ids': session.subjectIds,
      'settings': null,
      'answers': session.answers.map((k, v) => MapEntry(k.toString(), v)),
      'total_questions': session.questionIds.length,
      'bookmarked_question_ids': session.bookmarkedQuestionIds,
      'duration_minutes': session.durationMinutes,
      'time_spent_seconds': timeSpentSeconds,
      'started_at': startedAt.toIso8601String(),
      'submitted_at': submittedAt.toIso8601String(),
    });
  }

  Future<void> enqueueBookmarkToggle(int questionId, {required bool bookmarked}) {
    return enqueue(
      bookmarked ? PendingOperationType.bookmarkQuestion : PendingOperationType.unbookmarkQuestion,
      {'question_id': questionId},
    );
  }

  Future<void> enqueue(String type, Map<String, dynamic> payload) async {
    final op = PendingOperation(
      id: _uuid.v4(),
      type: type,
      payload: jsonEncode(payload),
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );
    await HiveSetup.pendingOperationsBox.put(op.id, op);
  }

  List<PendingOperation> get pending => HiveSetup.pendingOperationsBox.values.toList();

  Future<void> remove(String id) => HiveSetup.pendingOperationsBox.delete(id);

  Future<void> markFailed(String id, String error) async {
    final op = HiveSetup.pendingOperationsBox.get(id);
    if (op == null) return;
    op.retryCount++;
    op.lastError = error;
    await op.save();
  }
}

@Riverpod(keepAlive: true)
OfflineQueueService offlineQueueService(OfflineQueueServiceRef ref) => OfflineQueueService();
