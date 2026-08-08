// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookDetailControllerHash() =>
    r'4e2fbaee31bc6320be3773d902fb75605071a92d';

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

abstract class _$BookDetailController
    extends BuildlessAutoDisposeAsyncNotifier<BookDetail> {
  late final String slug;

  FutureOr<BookDetail> build(String slug);
}

/// See also [BookDetailController].
@ProviderFor(BookDetailController)
const bookDetailControllerProvider = BookDetailControllerFamily();

/// See also [BookDetailController].
class BookDetailControllerFamily extends Family<AsyncValue<BookDetail>> {
  /// See also [BookDetailController].
  const BookDetailControllerFamily();

  /// See also [BookDetailController].
  BookDetailControllerProvider call(String slug) {
    return BookDetailControllerProvider(slug);
  }

  @override
  BookDetailControllerProvider getProviderOverride(
    covariant BookDetailControllerProvider provider,
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
  String? get name => r'bookDetailControllerProvider';
}

/// See also [BookDetailController].
class BookDetailControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<BookDetailController, BookDetail> {
  /// See also [BookDetailController].
  BookDetailControllerProvider(String slug)
    : this._internal(
        () => BookDetailController()..slug = slug,
        from: bookDetailControllerProvider,
        name: r'bookDetailControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookDetailControllerHash,
        dependencies: BookDetailControllerFamily._dependencies,
        allTransitiveDependencies:
            BookDetailControllerFamily._allTransitiveDependencies,
        slug: slug,
      );

  BookDetailControllerProvider._internal(
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
  FutureOr<BookDetail> runNotifierBuild(
    covariant BookDetailController notifier,
  ) {
    return notifier.build(slug);
  }

  @override
  Override overrideWith(BookDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookDetailControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<BookDetailController, BookDetail>
  createElement() {
    return _BookDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDetailControllerProvider && other.slug == slug;
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
mixin BookDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<BookDetail> {
  /// The parameter `slug` of this provider.
  String get slug;
}

class _BookDetailControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          BookDetailController,
          BookDetail
        >
    with BookDetailControllerRef {
  _BookDetailControllerProviderElement(super.provider);

  @override
  String get slug => (origin as BookDetailControllerProvider).slug;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
