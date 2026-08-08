import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/connectivity/connectivity_provider.dart';
import '../../../../core/storage/hive_setup.dart';
import '../cbt_api.dart';
import '../models/offline_session_model.dart';
import '../models/pending_operation_model.dart';
import 'cbt_sync_service.dart';
import 'offline_queue_service.dart';

part 'sync_manager.g.dart';

/// Orchestrates every piece of the offline-sync engine: drains the pending
/// operation queue (offline exam sessions via the batch `/sync/flush`
/// endpoint; bookmark toggles individually, since the backend's toggle
/// endpoint has no batch form), then refreshes the local question bank.
/// Fires automatically on every offline→online transition (watches
/// `connectivityProvider`, per `phase4.md`), and can be triggered manually
/// (e.g. pull-to-refresh, post-login).
@Riverpod(keepAlive: true)
class SyncManager extends _$SyncManager {
  @override
  FutureOr<void> build() {
    var wasOnline = false;
    ref.listen(connectivityProvider, (previous, next) {
      final isOnline = next.valueOrNull ?? false;
      if (isOnline && !wasOnline) {
        syncNow();
      }
      wasOnline = isOnline;
    });
  }

  Future<void> syncNow() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(cbtApiProvider);
      final queue = ref.read(offlineQueueServiceProvider);
      final syncService = ref.read(cbtSyncServiceProvider);

      await _flushQueue(api, queue);
      await syncService.syncExamTypesAndSubjects();
      await syncService.syncAllQuestionBanks();
    });
  }

  Future<void> _flushQueue(CbtApi api, OfflineQueueService queue) async {
    final pending = queue.pending;
    if (pending.isEmpty) return;

    final sessionOps = pending.where((op) => op.type == PendingOperationType.submitSession).toList();
    final bookmarkOps = pending
        .where(
          (op) =>
              op.type == PendingOperationType.bookmarkQuestion || op.type == PendingOperationType.unbookmarkQuestion,
        )
        .toList();

    if (sessionOps.isNotEmpty) {
      final operations = sessionOps
          .map((op) => {'type': op.type, 'payload': jsonDecode(op.payload) as Map<String, dynamic>})
          .toList();

      final results = await api.syncFlush(operations);
      for (var i = 0; i < sessionOps.length; i++) {
        final result = i < results.length ? results[i] as Map<String, dynamic> : null;
        final status = result?['status'] as String?;
        if (status == 'synced' || status == 'already_synced') {
          await queue.remove(sessionOps[i].id);
          await _markSessionSynced(sessionOps[i]);
        } else {
          await queue.markFailed(sessionOps[i].id, result?['message'] as String? ?? 'sync failed');
        }
      }
    }

    for (final op in bookmarkOps) {
      try {
        final payload = jsonDecode(op.payload) as Map<String, dynamic>;
        await api.toggleBookmark(payload['question_id'] as int);
        await queue.remove(op.id);
      } catch (e) {
        await queue.markFailed(op.id, e.toString());
      }
    }
  }

  Future<void> _markSessionSynced(PendingOperation op) async {
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;
    final offlineUuid = payload['offline_uuid'] as String?;
    if (offlineUuid == null) return;

    final box = HiveSetup.offlineSessionsBox;
    OfflineSessionModel? session;
    for (final s in box.values) {
      if (s.offlineUuid == offlineUuid) {
        session = s;
        break;
      }
    }
    if (session == null) return;
    session.isSynced = true;
    await session.save();
  }
}
