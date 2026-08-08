// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$connectivityHash() => r'16283502e81abdd8f93ae5d0d19baac6c68ffbe1';

/// Global connectivity stream — the single source of truth for
/// online/offline state (`uiuxrules.md` §29: "do not make every screen
/// independently implement connectivity logic; use centralized
/// infrastructure with granular UI consumption"). `phase4.md`'s CBT/sync
/// spec names this exact provider; every feature (not just CBT) should
/// consume it rather than talking to `connectivity_plus` directly.
///
/// Copied from [connectivity].
@ProviderFor(connectivity)
final connectivityProvider = StreamProvider<bool>.internal(
  connectivity,
  name: r'connectivityProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectivityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConnectivityRef = StreamProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
