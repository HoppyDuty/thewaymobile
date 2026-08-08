// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncManagerHash() => r'edf7330a5113754f440cf9be1415296521bc6048';

/// Orchestrates every piece of the offline-sync engine: drains the pending
/// operation queue (offline exam sessions via the batch `/sync/flush`
/// endpoint; bookmark toggles individually, since the backend's toggle
/// endpoint has no batch form), then refreshes the local question bank.
/// Fires automatically on every offline→online transition (watches
/// `connectivityProvider`, per `phase4.md`), and can be triggered manually
/// (e.g. pull-to-refresh, post-login).
///
/// Copied from [SyncManager].
@ProviderFor(SyncManager)
final syncManagerProvider = AsyncNotifierProvider<SyncManager, void>.internal(
  SyncManager.new,
  name: r'syncManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncManager = AsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
