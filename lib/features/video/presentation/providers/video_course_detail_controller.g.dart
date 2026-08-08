// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_course_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$videoCourseDetailControllerHash() =>
    r'6b396080bc564822e7236853331b16aee9a8cc07';

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

abstract class _$VideoCourseDetailController
    extends BuildlessAutoDisposeAsyncNotifier<VideoCourseDetail> {
  late final String slug;

  FutureOr<VideoCourseDetail> build(String slug);
}

/// See also [VideoCourseDetailController].
@ProviderFor(VideoCourseDetailController)
const videoCourseDetailControllerProvider = VideoCourseDetailControllerFamily();

/// See also [VideoCourseDetailController].
class VideoCourseDetailControllerFamily
    extends Family<AsyncValue<VideoCourseDetail>> {
  /// See also [VideoCourseDetailController].
  const VideoCourseDetailControllerFamily();

  /// See also [VideoCourseDetailController].
  VideoCourseDetailControllerProvider call(String slug) {
    return VideoCourseDetailControllerProvider(slug);
  }

  @override
  VideoCourseDetailControllerProvider getProviderOverride(
    covariant VideoCourseDetailControllerProvider provider,
  ) {
    return call(provider.slug);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoCourseDetailControllerProvider';
}

/// See also [VideoCourseDetailController].
class VideoCourseDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          VideoCourseDetailController,
          VideoCourseDetail
        > {
  /// See also [VideoCourseDetailController].
  VideoCourseDetailControllerProvider(String slug)
    : this._internal(
        () => VideoCourseDetailController()..slug = slug,
        from: videoCourseDetailControllerProvider,
        name: r'videoCourseDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoCourseDetailControllerHash,
        dependencies: VideoCourseDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            VideoCourseDetailControllerFamily._allTransitiveDependencies,
        slug: slug,
      );

  VideoCourseDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.slug,
  }) : super.internal();

  final String slug;

  @override
  FutureOr<VideoCourseDetail> runNotifierBuild(
    covariant VideoCourseDetailController notifier,
  ) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(VideoCourseDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoCourseDetailControllerProvider._internal(
        () => create()..slug = slug,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        slug: slug,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    VideoCourseDetailController,
    VideoCourseDetail
  >
  createElement() {
    return _VideoCourseDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoCourseDetailControllerProvider && other.slug == slug;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, slug.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoCourseDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<VideoCourseDetail> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _VideoCourseDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          VideoCourseDetailController,
          VideoCourseDetail
        >
    with VideoCourseDetailControllerRef {
  _VideoCourseDetailControllerProviderElement(super.provider);

  @override
  String get slug => (origin as VideoCourseDetailControllerProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
