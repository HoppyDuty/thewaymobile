// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_download_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localVideoDownloadsHash() =>
    r'c8408c678846344e001b3b3184367abd67ba93e6';

/// Every locally-saved video, expired ones cleaned up (file + Hive record)
/// as they're found rather than merely hidden — keeps device storage from
/// silently accumulating stale downloads.
///
/// Copied from [localVideoDownloads].
@ProviderFor(localVideoDownloads)
final localVideoDownloadsProvider =
    AutoDisposeFutureProvider<List<DownloadedVideoModel>>.internal(
      localVideoDownloads,
      name: r'localVideoDownloadsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localVideoDownloadsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalVideoDownloadsRef =
    AutoDisposeFutureProviderRef<List<DownloadedVideoModel>>;
String _$videoDownloadControllerHash() =>
    r'5e5bab84f063e8bf17229cfae883faa31247a66b';

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

abstract class _$VideoDownloadController
    extends BuildlessAutoDisposeNotifier<VideoDownloadProgress> {
  late final int lessonId;

  VideoDownloadProgress build(int lessonId);
}

/// Drives a single lesson's download end-to-end: queues it server-side
/// (yt-dlp fetches the YouTube video onto the server), polls until that's
/// done, then pulls the actual file bytes down to the device over
/// `/videos/downloads/{token}/file` and records it in Hive — this last step
/// is what makes "My Videos" play back with zero connectivity, rather than
/// just tracking a server-side cache the app could never actually watch.
///
/// Copied from [VideoDownloadController].
@ProviderFor(VideoDownloadController)
const videoDownloadControllerProvider = VideoDownloadControllerFamily();

/// Drives a single lesson's download end-to-end: queues it server-side
/// (yt-dlp fetches the YouTube video onto the server), polls until that's
/// done, then pulls the actual file bytes down to the device over
/// `/videos/downloads/{token}/file` and records it in Hive — this last step
/// is what makes "My Videos" play back with zero connectivity, rather than
/// just tracking a server-side cache the app could never actually watch.
///
/// Copied from [VideoDownloadController].
class VideoDownloadControllerFamily extends Family<VideoDownloadProgress> {
  /// Drives a single lesson's download end-to-end: queues it server-side
  /// (yt-dlp fetches the YouTube video onto the server), polls until that's
  /// done, then pulls the actual file bytes down to the device over
  /// `/videos/downloads/{token}/file` and records it in Hive — this last step
  /// is what makes "My Videos" play back with zero connectivity, rather than
  /// just tracking a server-side cache the app could never actually watch.
  ///
  /// Copied from [VideoDownloadController].
  const VideoDownloadControllerFamily();

  /// Drives a single lesson's download end-to-end: queues it server-side
  /// (yt-dlp fetches the YouTube video onto the server), polls until that's
  /// done, then pulls the actual file bytes down to the device over
  /// `/videos/downloads/{token}/file` and records it in Hive — this last step
  /// is what makes "My Videos" play back with zero connectivity, rather than
  /// just tracking a server-side cache the app could never actually watch.
  ///
  /// Copied from [VideoDownloadController].
  VideoDownloadControllerProvider call(int lessonId) {
    return VideoDownloadControllerProvider(lessonId);
  }

  @override
  VideoDownloadControllerProvider getProviderOverride(
    covariant VideoDownloadControllerProvider provider,
  ) {
    return call(provider.lessonId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'videoDownloadControllerProvider';
}

/// Drives a single lesson's download end-to-end: queues it server-side
/// (yt-dlp fetches the YouTube video onto the server), polls until that's
/// done, then pulls the actual file bytes down to the device over
/// `/videos/downloads/{token}/file` and records it in Hive — this last step
/// is what makes "My Videos" play back with zero connectivity, rather than
/// just tracking a server-side cache the app could never actually watch.
///
/// Copied from [VideoDownloadController].
class VideoDownloadControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<
          VideoDownloadController,
          VideoDownloadProgress
        > {
  /// Drives a single lesson's download end-to-end: queues it server-side
  /// (yt-dlp fetches the YouTube video onto the server), polls until that's
  /// done, then pulls the actual file bytes down to the device over
  /// `/videos/downloads/{token}/file` and records it in Hive — this last step
  /// is what makes "My Videos" play back with zero connectivity, rather than
  /// just tracking a server-side cache the app could never actually watch.
  ///
  /// Copied from [VideoDownloadController].
  VideoDownloadControllerProvider(int lessonId)
    : this._internal(
        () => VideoDownloadController()..lessonId = lessonId,
        from: videoDownloadControllerProvider,
        name: r'videoDownloadControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$videoDownloadControllerHash,
        dependencies: VideoDownloadControllerFamily._dependencies,
        allTransitiveDependencies:
            VideoDownloadControllerFamily._allTransitiveDependencies,
        lessonId: lessonId,
      );

  VideoDownloadControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.lessonId,
  }) : super.internal();

  final int lessonId;

  @override
  VideoDownloadProgress runNotifierBuild(
    covariant VideoDownloadController notifier,
  ) {
    return notifier.build(lessonId);
  }

  @override
  Override overrideWith(VideoDownloadController Function() create) {
    return ProviderOverride(
      origin: this,
      override: VideoDownloadControllerProvider._internal(
        () => create()..lessonId = lessonId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        lessonId: lessonId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    VideoDownloadController,
    VideoDownloadProgress
  >
  createElement() {
    return _VideoDownloadControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VideoDownloadControllerProvider &&
        other.lessonId == lessonId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, lessonId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VideoDownloadControllerRef
    on AutoDisposeNotifierProviderRef<VideoDownloadProgress> {
  /// The parameter `lessonId` of this provider.
  int get lessonId;
}

class _VideoDownloadControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          VideoDownloadController,
          VideoDownloadProgress
        >
    with VideoDownloadControllerRef {
  _VideoDownloadControllerProviderElement(super.provider);

  @override
  int get lessonId => (origin as VideoDownloadControllerProvider).lessonId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
