// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookListControllerHash() =>
    r'32a54e0de4b9a260646587b49fac2b51deed96db';

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

abstract class _$BookListController
    extends BuildlessAutoDisposeAsyncNotifier<BookListState> {
  late final ({int? categoryId, String? search}) filter;

  FutureOr<BookListState> build(({int? categoryId, String? search}) filter);
}

/// See also [BookListController].
@ProviderFor(BookListController)
const bookListControllerProvider = BookListControllerFamily();

/// See also [BookListController].
class BookListControllerFamily extends Family<AsyncValue<BookListState>> {
  /// See also [BookListController].
  const BookListControllerFamily();

  /// See also [BookListController].
  BookListControllerProvider call(({int? categoryId, String? search}) filter) {
    return BookListControllerProvider(filter);
  }

  @override
  BookListControllerProvider getProviderOverride(
    covariant BookListControllerProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookListControllerProvider';
}

/// See also [BookListController].
class BookListControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          BookListController,
          BookListState
        > {
  /// See also [BookListController].
  BookListControllerProvider(({int? categoryId, String? search}) filter)
    : this._internal(
        () => BookListController()..filter = filter,
        from: bookListControllerProvider,
        name: r'bookListControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookListControllerHash,
        dependencies: BookListControllerFamily._dependencies,
        allTransitiveDependencies:
            BookListControllerFamily._allTransitiveDependencies,
        filter: filter,
      );

  BookListControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final ({int? categoryId, String? search}) filter;

  @override
  FutureOr<BookListState> runNotifierBuild(
    covariant BookListController notifier,
  ) {
    return notifier.build(filter);
  }

  @override
  Override overrideWith(BookListController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookListControllerProvider._internal(
        () => create()..filter = filter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<BookListController, BookListState>
  createElement() {
    return _BookListControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookListControllerProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookListControllerRef
    on AutoDisposeAsyncNotifierProviderRef<BookListState> {
  /// The parameter `filter` of this provider.
  ({int? categoryId, String? search}) get filter;
}

class _BookListControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          BookListController,
          BookListState
        >
    with BookListControllerRef {
  _BookListControllerProviderElement(super.provider);

  @override
  ({int? categoryId, String? search}) get filter =>
      (origin as BookListControllerProvider).filter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
