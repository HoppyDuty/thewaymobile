// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_session_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$examSessionControllerHash() =>
    r'ad3e2346f1415a4930631c75b506e4854ae561fb';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ExamSessionController
    extends BuildlessAsyncNotifier<ExamSessionState> {
  late final String sessionKey;

  FutureOr<ExamSessionState> build(String sessionKey);
}

/// Drives a single exam attempt end-to-end: builds the question set
/// (online via `startSession`, falling back to `OfflineQuestionBuilder`
/// on any failure), ticks the timer, autosaves every answer to Hive so
/// nothing is ever lost, and scores on submit (authoritative online, a
/// local preview offline — queued for the real score once synced).
/// `keepAlive: true` (per session key) so the Exam → Result → Review
/// navigation chain can all read the same state without a disposal race —
/// this is an autoDispose-by-default family otherwise, and a stray frame
/// with zero watchers between `pushReplacement` calls could tear the
/// in-progress session down before the result screen ever reads it.
///
/// Copied from [ExamSessionController].
@ProviderFor(ExamSessionController)
const examSessionControllerProvider = ExamSessionControllerFamily();

/// Drives a single exam attempt end-to-end: builds the question set
/// (online via `startSession`, falling back to `OfflineQuestionBuilder`
/// on any failure), ticks the timer, autosaves every answer to Hive so
/// nothing is ever lost, and scores on submit (authoritative online, a
/// local preview offline — queued for the real score once synced).
/// `keepAlive: true` (per session key) so the Exam → Result → Review
/// navigation chain can all read the same state without a disposal race —
/// this is an autoDispose-by-default family otherwise, and a stray frame
/// with zero watchers between `pushReplacement` calls could tear the
/// in-progress session down before the result screen ever reads it.
///
/// Copied from [ExamSessionController].
class ExamSessionControllerFamily extends Family<AsyncValue<ExamSessionState>> {
  /// Drives a single exam attempt end-to-end: builds the question set
  /// (online via `startSession`, falling back to `OfflineQuestionBuilder`
  /// on any failure), ticks the timer, autosaves every answer to Hive so
  /// nothing is ever lost, and scores on submit (authoritative online, a
  /// local preview offline — queued for the real score once synced).
  /// `keepAlive: true` (per session key) so the Exam → Result → Review
  /// navigation chain can all read the same state without a disposal race —
  /// this is an autoDispose-by-default family otherwise, and a stray frame
  /// with zero watchers between `pushReplacement` calls could tear the
  /// in-progress session down before the result screen ever reads it.
  ///
  /// Copied from [ExamSessionController].
  const ExamSessionControllerFamily();

  /// Drives a single exam attempt end-to-end: builds the question set
  /// (online via `startSession`, falling back to `OfflineQuestionBuilder`
  /// on any failure), ticks the timer, autosaves every answer to Hive so
  /// nothing is ever lost, and scores on submit (authoritative online, a
  /// local preview offline — queued for the real score once synced).
  /// `keepAlive: true` (per session key) so the Exam → Result → Review
  /// navigation chain can all read the same state without a disposal race —
  /// this is an autoDispose-by-default family otherwise, and a stray frame
  /// with zero watchers between `pushReplacement` calls could tear the
  /// in-progress session down before the result screen ever reads it.
  ///
  /// Copied from [ExamSessionController].
  ExamSessionControllerProvider call(String sessionKey) {
    return ExamSessionControllerProvider(sessionKey);
  }

  @override
  ExamSessionControllerProvider getProviderOverride(
    covariant ExamSessionControllerProvider provider,
  ) {
    return call(provider.sessionKey);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'examSessionControllerProvider';
}

/// Drives a single exam attempt end-to-end: builds the question set
/// (online via `startSession`, falling back to `OfflineQuestionBuilder`
/// on any failure), ticks the timer, autosaves every answer to Hive so
/// nothing is ever lost, and scores on submit (authoritative online, a
/// local preview offline — queued for the real score once synced).
/// `keepAlive: true` (per session key) so the Exam → Result → Review
/// navigation chain can all read the same state without a disposal race —
/// this is an autoDispose-by-default family otherwise, and a stray frame
/// with zero watchers between `pushReplacement` calls could tear the
/// in-progress session down before the result screen ever reads it.
///
/// Copied from [ExamSessionController].
class ExamSessionControllerProvider
    extends AsyncNotifierProviderImpl<ExamSessionController, ExamSessionState> {
  /// Drives a single exam attempt end-to-end: builds the question set
  /// (online via `startSession`, falling back to `OfflineQuestionBuilder`
  /// on any failure), ticks the timer, autosaves every answer to Hive so
  /// nothing is ever lost, and scores on submit (authoritative online, a
  /// local preview offline — queued for the real score once synced).
  /// `keepAlive: true` (per session key) so the Exam → Result → Review
  /// navigation chain can all read the same state without a disposal race —
  /// this is an autoDispose-by-default family otherwise, and a stray frame
  /// with zero watchers between `pushReplacement` calls could tear the
  /// in-progress session down before the result screen ever reads it.
  ///
  /// Copied from [ExamSessionController].
  ExamSessionControllerProvider(String sessionKey)
    : this._internal(
        () => ExamSessionController()..sessionKey = sessionKey,
        from: examSessionControllerProvider,
        name: r'examSessionControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$examSessionControllerHash,
        dependencies: ExamSessionControllerFamily._dependencies,
        allTransitiveDependencies:
            ExamSessionControllerFamily._allTransitiveDependencies,
        sessionKey: sessionKey,
      );

  ExamSessionControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sessionKey,
  }) : super.internal();

  final String sessionKey;

  @override
  FutureOr<ExamSessionState> runNotifierBuild(
    covariant ExamSessionController notifier,
  ) {
    return notifier.build(sessionKey);
  }

  @override
  Override overrideWith(ExamSessionController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ExamSessionControllerProvider._internal(
        () => create()..sessionKey = sessionKey,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sessionKey: sessionKey,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<ExamSessionController, ExamSessionState>
  createElement() {
    return _ExamSessionControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ExamSessionControllerProvider &&
        other.sessionKey == sessionKey;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sessionKey.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ExamSessionControllerRef on AsyncNotifierProviderRef<ExamSessionState> {
  /// The parameter `sessionKey` of this provider.
  String get sessionKey;
}

class _ExamSessionControllerProviderElement
    extends
        AsyncNotifierProviderElement<ExamSessionController, ExamSessionState>
    with ExamSessionControllerRef {
  _ExamSessionControllerProviderElement(super.provider);

  @override
  String get sessionKey => (origin as ExamSessionControllerProvider).sessionKey;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
