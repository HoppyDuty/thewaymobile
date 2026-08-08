// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_download_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localSavedBooksHash() => r'd5744a3c49fe784ca46d423928f29b12e026e907';

/// Every locally-saved book, expired ones cleaned up (file + Hive record)
/// as they're found rather than merely hidden.
///
/// Copied from [localSavedBooks].
@ProviderFor(localSavedBooks)
final localSavedBooksProvider =
    AutoDisposeFutureProvider<List<SavedBookModel>>.internal(
      localSavedBooks,
      name: r'localSavedBooksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localSavedBooksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalSavedBooksRef = AutoDisposeFutureProviderRef<List<SavedBookModel>>;
String _$bookDownloadControllerHash() =>
    r'2908f3d4eb7b9ff2a3905c6326dbbb77d1c7bc8c';

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

abstract class _$BookDownloadController
    extends BuildlessAutoDisposeNotifier<BookDownloadProgress> {
  late final int bookId;

  BookDownloadProgress build(int bookId);
}

/// Saves a book's PDF for fully offline reading. Simpler than the video
/// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
/// returns a directly-fetchable Cloudinary URL immediately — no server-side
/// processing job to poll for, just a straight file download.
///
/// Copied from [BookDownloadController].
@ProviderFor(BookDownloadController)
const bookDownloadControllerProvider = BookDownloadControllerFamily();

/// Saves a book's PDF for fully offline reading. Simpler than the video
/// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
/// returns a directly-fetchable Cloudinary URL immediately — no server-side
/// processing job to poll for, just a straight file download.
///
/// Copied from [BookDownloadController].
class BookDownloadControllerFamily extends Family<BookDownloadProgress> {
  /// Saves a book's PDF for fully offline reading. Simpler than the video
  /// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
  /// returns a directly-fetchable Cloudinary URL immediately — no server-side
  /// processing job to poll for, just a straight file download.
  ///
  /// Copied from [BookDownloadController].
  const BookDownloadControllerFamily();

  /// Saves a book's PDF for fully offline reading. Simpler than the video
  /// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
  /// returns a directly-fetchable Cloudinary URL immediately — no server-side
  /// processing job to poll for, just a straight file download.
  ///
  /// Copied from [BookDownloadController].
  BookDownloadControllerProvider call(int bookId) {
    return BookDownloadControllerProvider(bookId);
  }

  @override
  BookDownloadControllerProvider getProviderOverride(
    covariant BookDownloadControllerProvider provider,
  ) {
    return call(provider.bookId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookDownloadControllerProvider';
}

/// Saves a book's PDF for fully offline reading. Simpler than the video
/// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
/// returns a directly-fetchable Cloudinary URL immediately — no server-side
/// processing job to poll for, just a straight file download.
///
/// Copied from [BookDownloadController].
class BookDownloadControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          BookDownloadController,
          BookDownloadProgress
        > {
  /// Saves a book's PDF for fully offline reading. Simpler than the video
  /// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
  /// returns a directly-fetchable Cloudinary URL immediately — no server-side
  /// processing job to poll for, just a straight file download.
  ///
  /// Copied from [BookDownloadController].
  BookDownloadControllerProvider(int bookId)
    : this._internal(
        () => BookDownloadController()..bookId = bookId,
        from: bookDownloadControllerProvider,
        name: r'bookDownloadControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$bookDownloadControllerHash,
        dependencies: BookDownloadControllerFamily._dependencies,
        allTransitiveDependencies:
            BookDownloadControllerFamily._allTransitiveDependencies,
        bookId: bookId,
      );

  BookDownloadControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookId,
  }) : super.internal();

  final int bookId;

  @override
  BookDownloadProgress runNotifierBuild(
    covariant BookDownloadController notifier,
  ) {
    return notifier.build(bookId);
  }

  @override
  Override overrideWith(BookDownloadController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookDownloadControllerProvider._internal(
        () => create()..bookId = bookId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookId: bookId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    BookDownloadController,
    BookDownloadProgress
  >
  createElement() {
    return _BookDownloadControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookDownloadControllerProvider && other.bookId == bookId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookDownloadControllerRef
    on AutoDisposeNotifierProviderRef<BookDownloadProgress> {
  /// The parameter `bookId` of this provider.
  int get bookId;
}

class _BookDownloadControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          BookDownloadController,
          BookDownloadProgress
        >
    with BookDownloadControllerRef {
  _BookDownloadControllerProviderElement(super.provider);

  @override
  int get bookId => (origin as BookDownloadControllerProvider).bookId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
