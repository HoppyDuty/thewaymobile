import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'pending_operation_model.g.dart';

/// Operation kinds the offline queue can carry — deliberately generic so
/// non-CBT features (e.g. a future offline "like a news article") can reuse
/// the same queue/sync-manager machinery.
class PendingOperationType {
  static const submitSession = 'submit_session';
  static const bookmarkQuestion = 'bookmark_question';
  static const unbookmarkQuestion = 'unbookmark_question';
}

/// A single not-yet-synced mutation, persisted so it survives an app kill
/// and is retried by `SyncManager` on the next connectivity window.
///
/// Extends [HiveObject] (rather than being a plain class) so an instance
/// already stored in a box can call `.save()` on itself after an in-place
/// mutation (e.g. bumping `retryCount`) instead of needing the caller to
/// re-`put()` it under its key.
@HiveType(typeId: kHiveTypePendingOperation)
class PendingOperation extends HiveObject {
  PendingOperation({
    required this.id,
    required this.type,
    required this.payload,
    this.retryCount = 0,
    required this.createdAt,
    this.lastError,
  });

  /// UUID — its own identity, independent of whatever entity it references.
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type;

  /// JSON-encoded request body for this operation.
  @HiveField(2)
  final String payload;

  @HiveField(3)
  int retryCount;

  /// Unix timestamp (seconds).
  @HiveField(4)
  final int createdAt;

  @HiveField(5)
  String? lastError;
}
