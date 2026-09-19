// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_courses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoCoursesControllerHash() =>
    r'cf61c02fb8dac7232231d44e4e6fa7e926f4df39';

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

abstract class _$VideoCoursesController
    extends BuildlessAutoDisposeAsyncNotifier<VideoCoursesState> {
  late final int? categoryId;

  FutureOr<VideoCoursesState> build(int? categoryId);
}

/// Family keyed by category id (null = all courses) — switching the
/// category filter chip just watches a different provider instance, each
/// with its own independent pagination state.
///
/// Copied from [VideoCoursesController].
@ProviderFor(VideoCoursesController)
const videoCoursesControllerProvider = VideoCoursesControllerFamily();

/// Family keyed by category id (null = all courses) — switching the
/// category filter chip just watches a different provider instance, each
/// with its own independent pagination state.
///
/// Copied from [VideoCoursesController].
class VideoCoursesControllerFamily
    extends Family<AsyncValue<VideoCoursesState>> {
  /// Family keyed by category id (null = all courses) — switching the
  /// category filter chip just watches a different provider instance, each
  /// with its own independent pagination state.
  ///
  /// Copied from [VideoCoursesController].
  const VideoCoursesControllerFamily();

  /// Family keyed by category id (null = all courses) — switching the
  /// category filter chip just watches a different provider instance, each
  /// with its own independent pagination state.
  ///
  /// Copied from [VideoCoursesController].
  VideoCoursesControllerProvider call(int? categoryId) {
    return VideoCoursesControllerProvider(categoryId);
  }

  @override
  VideoCoursesControllerProvider getProviderOverride(
    covariant VideoCoursesControllerProvider provider,
  ) {
    return call(provider.categoryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoCoursesControllerProvider';
}

/// Family keyed by category id (null = all courses) — switching the
/// category filter chip just watches a different provider instance, each
/// with its own independent pagination state.
///
/// Copied from [VideoCoursesController].
class VideoCoursesControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          VideoCoursesController,
          VideoCoursesState
        > {
  /// Family keyed by category id (null = all courses) — switching the
  /// category filter chip just watches a different provider instance, each
  /// with its own independent pagination state.
  ///
  /// Copied from [VideoCoursesController].
  VideoCoursesControllerProvider(int? categoryId)
    : this._internal(
        () => VideoCoursesController()..categoryId = categoryId,
        from: videoCoursesControllerProvider,
        name: r'videoCoursesControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoCoursesControllerHash,
        dependencies: VideoCoursesControllerFamily._dependencies,
        allTransitiveDependencies:
            VideoCoursesControllerFamily._allTransitiveDependencies,
        categoryId: categoryId,
      );

  VideoCoursesControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int? categoryId;

  @override
  FutureOr<VideoCoursesState> runNotifierBuild(
    covariant VideoCoursesController notifier,
  ) {
    return notifier.build(categoryId);
  }

  @override
  Override overrideWith(VideoCoursesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoCoursesControllerProvider._internal(
        () => create()..categoryId = categoryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    VideoCoursesController,
    VideoCoursesState
  >
  createElement() {
    return _VideoCoursesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoCoursesControllerProvider &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoCoursesControllerRef
    on AutoDisposeAsyncNotifierProviderRef<VideoCoursesState> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _VideoCoursesControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          VideoCoursesController,
          VideoCoursesState
        >
    with VideoCoursesControllerRef {
  _VideoCoursesControllerProviderElement(super.provider);

  @override
  int? get categoryId => (origin as VideoCoursesControllerProvider).categoryId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
