// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_types_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examTypesControllerHash() =>
    r'4d40b239cf919457ebedfddbda24a54c19e496f1';

/// Exam types shown on the CBT tab / topical-study picker. Always reads
/// from Hive first (instant, offline-safe) and syncs in the background
/// the first time the box is empty — once synced, this list survives
/// indefinitely offline (no TTL), matching the "2+ months offline" CBT
/// requirement.
///
/// Copied from [ExamTypesController].
@ProviderFor(ExamTypesController)
final examTypesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      ExamTypesController,
      List<ExamTypeModel>
    >.internal(
      ExamTypesController.new,
      name: r'examTypesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$examTypesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ExamTypesController = AutoDisposeAsyncNotifier<List<ExamTypeModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
