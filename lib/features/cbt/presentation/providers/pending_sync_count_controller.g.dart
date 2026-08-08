// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_sync_count_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingSyncCountHash() => r'eafe8691823b8da3ed40a30a97c057ac1e4f5e72';

/// Reactive count of not-yet-synced offline operations (queued exam
/// submissions, bookmark toggles) — re-emits on every Hive box change so
/// [SyncBadge] updates live as `OfflineQueueService`/`SyncManager` drain it.
///
/// Copied from [pendingSyncCount].
@ProviderFor(pendingSyncCount)
final pendingSyncCountProvider = AutoDisposeStreamProvider<int>.internal(
  pendingSyncCount,
  name: r'pendingSyncCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pendingSyncCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PendingSyncCountRef = AutoDisposeStreamProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
