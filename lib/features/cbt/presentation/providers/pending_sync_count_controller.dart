import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';

part 'pending_sync_count_controller.g.dart';

/// Reactive count of not-yet-synced offline operations (queued exam
/// submissions, bookmark toggles) — re-emits on every Hive box change so
/// [SyncBadge] updates live as `OfflineQueueService`/`SyncManager` drain it.
@riverpod
Stream<int> pendingSyncCount(PendingSyncCountRef ref) async* {
  final box = HiveSetup.pendingOperationsBox;
  yield box.length;
  await for (final _ in box.watch()) {
    yield box.length;
  }
}
