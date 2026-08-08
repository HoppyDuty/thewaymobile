// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_exam_configs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingExamConfigsHash() =>
    r'a13f01d0a17693ace4aeed2e04542896bb5adf04';

/// A short-lived, in-memory handoff from the setup screen to
/// `ExamSessionController`: the setup screen generates a session key,
/// stashes the config here, then pushes `/cbt/exam/<key>` — the exam
/// screen's controller reads (and immediately clears) its entry on first
/// build. Avoids needing a complex-equality family parameter just to pass
/// a full config object through go_router.
///
/// Copied from [PendingExamConfigs].
@ProviderFor(PendingExamConfigs)
final pendingExamConfigsProvider =
    NotifierProvider<
      PendingExamConfigs,
      Map<String, ExamLaunchConfig>
    >.internal(
      PendingExamConfigs.new,
      name: r'pendingExamConfigsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingExamConfigsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingExamConfigs = Notifier<Map<String, ExamLaunchConfig>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
