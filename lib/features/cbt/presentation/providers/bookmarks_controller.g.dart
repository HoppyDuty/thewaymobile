// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookmarksControllerHash() =>
    r'f6d06f1d96e1302a87e4119a55fbe39e04a35d5d';

/// Bookmarked questions ("My Questions") — the id list comes from the
/// server when online (and is cached to Hive `settings_box` for offline
/// use), then resolved against the locally-synced question bank so this
/// works fully offline once both have synced at least once.
///
/// Copied from [BookmarksController].
@ProviderFor(BookmarksController)
final bookmarksControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      BookmarksController,
      List<QuestionModel>
    >.internal(
      BookmarksController.new,
      name: r'bookmarksControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$bookmarksControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$BookmarksController = AutoDisposeAsyncNotifier<List<QuestionModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
