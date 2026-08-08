import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'delta_checkpoint_model.g.dart';

/// Tracks how far this device's local question bank is synced for a given
/// exam type, so `CbtSyncService` only ever requests the delta since
/// [lastSyncedAt] instead of re-downloading the whole bank.
@HiveType(typeId: kHiveTypeDeltaCheckpoint)
class DeltaCheckpointModel {
  DeltaCheckpointModel({
    required this.examTypeId,
    required this.lastSyncedAt,
    required this.totalQuestions,
    this.checksum,
  });

  @HiveField(0)
  final int examTypeId;

  /// Unix timestamp (seconds) of the last successful delta sync for this
  /// exam type — sent back as `since` on the next `/cbt/questions/delta` call.
  @HiveField(1)
  int lastSyncedAt;

  @HiveField(2)
  int totalQuestions;

  /// Optional server-provided checksum used to detect drift and trigger a
  /// full resync if the local count/hash ever disagrees with the backend.
  @HiveField(3)
  String? checksum;
}
