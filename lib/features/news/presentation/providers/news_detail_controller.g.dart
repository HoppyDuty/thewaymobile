// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsDetailControllerHash() =>
    r'cc7f9616fac3ef1be5e5e2ef3ef532046f15eb09';

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

abstract class _$NewsDetailController
    extends BuildlessAutoDisposeAsyncNotifier<NewsArticleDetail> {
  late final String slug;

  FutureOr<NewsArticleDetail> build(String slug);
}

/// See also [NewsDetailController].
@ProviderFor(NewsDetailController)
const newsDetailControllerProvider = NewsDetailControllerFamily();

/// See also [NewsDetailController].
class NewsDetailControllerFamily extends Family<AsyncValue<NewsArticleDetail>> {
  /// See also [NewsDetailController].
  const NewsDetailControllerFamily();

  /// See also [NewsDetailController].
  NewsDetailControllerProvider call(String slug) {
    return NewsDetailControllerProvider(slug);
  }

  @override
  NewsDetailControllerProvider getProviderOverride(
    covariant NewsDetailControllerProvider provider,
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
  String? get name => r'newsDetailControllerProvider';
}

/// See also [NewsDetailController].
class NewsDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NewsDetailController,
          NewsArticleDetail
        > {
  /// See also [NewsDetailController].
  NewsDetailControllerProvider(String slug)
    : this._internal(
        () => NewsDetailController()..slug = slug,
        from: newsDetailControllerProvider,
        name: r'newsDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$newsDetailControllerHash,
        dependencies: NewsDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            NewsDetailControllerFamily._allTransitiveDependencies,
        slug: slug,
      );

  NewsDetailControllerProvider._internal(
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
  FutureOr<NewsArticleDetail> runNotifierBuild(
    covariant NewsDetailController notifier,
  ) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(NewsDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: NewsDetailControllerProvider._internal(
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
    NewsDetailController,
    NewsArticleDetail
  >
  createElement() {
    return _NewsDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsDetailControllerProvider && other.slug == slug;
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
mixin NewsDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<NewsArticleDetail> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _NewsDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NewsDetailController,
          NewsArticleDetail
        >
    with NewsDetailControllerRef {
  _NewsDetailControllerProviderElement(super.provider);

  @override
  String get slug => (origin as NewsDetailControllerProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
