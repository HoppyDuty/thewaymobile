// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_comments_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsCommentsControllerHash() =>
    r'71012138efcc8119df669fc04d4d243712bb46a3';

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

abstract class _$NewsCommentsController
    extends BuildlessAutoDisposeAsyncNotifier<NewsCommentsState> {
  late final int articleId;

  FutureOr<NewsCommentsState> build(int articleId);
}

/// See also [NewsCommentsController].
@ProviderFor(NewsCommentsController)
const newsCommentsControllerProvider = NewsCommentsControllerFamily();

/// See also [NewsCommentsController].
class NewsCommentsControllerFamily
    extends Family<AsyncValue<NewsCommentsState>> {
  /// See also [NewsCommentsController].
  const NewsCommentsControllerFamily();

  /// See also [NewsCommentsController].
  NewsCommentsControllerProvider call(int articleId) {
    return NewsCommentsControllerProvider(articleId);
  }

  @override
  NewsCommentsControllerProvider getProviderOverride(
    covariant NewsCommentsControllerProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'newsCommentsControllerProvider';
}

/// See also [NewsCommentsController].
class NewsCommentsControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          NewsCommentsController,
          NewsCommentsState
        > {
  /// See also [NewsCommentsController].
  NewsCommentsControllerProvider(int articleId)
    : this._internal(
        () => NewsCommentsController()..articleId = articleId,
        from: newsCommentsControllerProvider,
        name: r'newsCommentsControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$newsCommentsControllerHash,
        dependencies: NewsCommentsControllerFamily._dependencies,
        allTransitiveDependencies:
            NewsCommentsControllerFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  NewsCommentsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final int articleId;

  @override
  FutureOr<NewsCommentsState> runNotifierBuild(
    covariant NewsCommentsController notifier,
  ) {
    return notifier.build(articleId);
  }

  @override
  Override overrideWith(NewsCommentsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: NewsCommentsControllerProvider._internal(
        () => create()..articleId = articleId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    NewsCommentsController,
    NewsCommentsState
  >
  createElement() {
    return _NewsCommentsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NewsCommentsControllerProvider &&
        other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NewsCommentsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<NewsCommentsState> {
  /// The parameter `articleId` of this provider.
  int get articleId;
}

class _NewsCommentsControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          NewsCommentsController,
          NewsCommentsState
        >
    with NewsCommentsControllerRef {
  _NewsCommentsControllerProviderElement(super.provider);

  @override
  int get articleId => (origin as NewsCommentsControllerProvider).articleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
