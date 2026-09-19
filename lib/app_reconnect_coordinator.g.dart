// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_reconnect_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appReconnectCoordinatorHash() =>
    r'969bbb9a58e83cd2497e24b44a3d610fa233e2b0';

/// App-wide offline→online reconnect trigger (`UI_UX_RULES.md` §11).
///
/// Previously only CBT's `SyncManager` listened for reconnects, and only
/// once something had built it — in practice, only after the user visited
/// the CBT tab, so a session that never opened CBT never synced at all.
/// Watched once from [TheWayApp]'s root (`app.dart`), so this is alive for
/// the whole session regardless of which tab the user visits, and fans a
/// single reconnect event out to every feature with its own offline-aware
/// provider instead of each screen re-implementing this independently
/// (`uiuxrules.md` §29 — centralized connectivity infrastructure, not
/// per-screen logic).
///
/// Copied from [AppReconnectCoordinator].
@ProviderFor(AppReconnectCoordinator)
final appReconnectCoordinatorProvider =
    NotifierProvider<AppReconnectCoordinator, void>.internal(
      AppReconnectCoordinator.new,
      name: r'appReconnectCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appReconnectCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppReconnectCoordinator = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
