// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weak_area_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weakAreaControllerHash() =>
    r'cae1d96769a1014ec570f53cbca85664b5b2af44';

/// No auto-fetch on build — analysis is user-triggered (it costs an AI
/// call against a 5/day quota with a 6h regen cooldown), so this starts
/// empty until [analyze] is called.
///
/// Copied from [WeakAreaController].
@ProviderFor(WeakAreaController)
final weakAreaControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      WeakAreaController,
      WeakAreaAnalysis?
    >.internal(
      WeakAreaController.new,
      name: r'weakAreaControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$weakAreaControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WeakAreaController = AutoDisposeAsyncNotifier<WeakAreaAnalysis?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
