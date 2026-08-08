import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/hive_setup.dart';
import '../../data/models/downloaded_video_model.dart';
import '../../data/models/video_lesson.dart';
import '../../data/video_api.dart';

part 'video_download_controller.g.dart';

enum VideoDownloadStatus { idle, queued, processingOnServer, downloadingToDevice, completed, failed }

class VideoDownloadProgress {
  const VideoDownloadProgress({required this.status, this.progress = 0, this.error});

  final VideoDownloadStatus status;

  /// 0.0–1.0, only meaningful while [status] is [VideoDownloadStatus.downloadingToDevice].
  final double progress;
  final String? error;

  bool get isActive =>
      status == VideoDownloadStatus.queued ||
      status == VideoDownloadStatus.processingOnServer ||
      status == VideoDownloadStatus.downloadingToDevice;
}

/// Drives a single lesson's download end-to-end: queues it server-side
/// (yt-dlp fetches the YouTube video onto the server), polls until that's
/// done, then pulls the actual file bytes down to the device over
/// `/videos/downloads/{token}/file` and records it in Hive — this last step
/// is what makes "My Videos" play back with zero connectivity, rather than
/// just tracking a server-side cache the app could never actually watch.
@riverpod
class VideoDownloadController extends _$VideoDownloadController {
  @override
  VideoDownloadProgress build(int lessonId) {
    final existing = HiveSetup.videoDownloadsBox.get(lessonId);
    if (existing != null && !existing.isExpired) {
      return const VideoDownloadProgress(status: VideoDownloadStatus.completed, progress: 1);
    }
    return const VideoDownloadProgress(status: VideoDownloadStatus.idle);
  }

  Future<void> start({
    required VideoLesson lesson,
    required int courseId,
    required String courseSlug,
    String quality = '720p',
  }) async {
    if (state.isActive) return;

    state = const VideoDownloadProgress(status: VideoDownloadStatus.queued);
    try {
      final api = ref.read(videoApiProvider);
      var result = await api.requestDownload(lesson.id, quality: quality);
      var downloadToken = result.downloadToken;
      var serverStatus = result.status;

      if (serverStatus != 'completed') {
        state = const VideoDownloadProgress(status: VideoDownloadStatus.processingOnServer);
        for (var attempt = 0; attempt < 100; attempt++) {
          await Future.delayed(const Duration(seconds: 3));
          final poll = await api.getDownloadStatus(downloadToken);
          serverStatus = poll.status;
          if (serverStatus == 'completed') break;
          if (serverStatus == 'failed' || serverStatus == 'expired') {
            state = VideoDownloadProgress(
              status: VideoDownloadStatus.failed,
              error: 'The server could not prepare this video for download.',
            );
            return;
          }
        }
        if (serverStatus != 'completed') {
          state = const VideoDownloadProgress(
            status: VideoDownloadStatus.failed,
            error: 'Download is taking longer than expected. Try again shortly.',
          );
          return;
        }
      }

      state = const VideoDownloadProgress(status: VideoDownloadStatus.downloadingToDevice, progress: 0);

      final docsDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${docsDir.path}/video_downloads');
      if (!await videoDir.exists()) await videoDir.create(recursive: true);
      final localPath = '${videoDir.path}/${lesson.id}_$quality.mp4';

      await ref
          .read(apiClientProvider)
          .dio
          .download(
            '/videos/downloads/$downloadToken/file',
            localPath,
            onReceiveProgress: (received, total) {
              if (total > 0) {
                state = VideoDownloadProgress(status: VideoDownloadStatus.downloadingToDevice, progress: received / total);
              }
            },
          );

      final file = File(localPath);
      final fileSize = await file.length();
      final expiresAt = DateTime.tryParse(result.expiresAt)?.millisecondsSinceEpoch ?? 0;

      final model = DownloadedVideoModel(
        lessonId: lesson.id,
        courseId: courseId,
        courseSlug: courseSlug,
        title: lesson.title,
        thumbnailUrl: lesson.thumbnailUrl,
        durationSeconds: lesson.durationSeconds,
        quality: quality,
        localFilePath: localPath,
        fileSizeBytes: fileSize,
        downloadedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        expiresAt: expiresAt > 0 ? expiresAt ~/ 1000 : (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 30 * 86400,
      );
      await HiveSetup.videoDownloadsBox.put(lesson.id, model);

      state = const VideoDownloadProgress(status: VideoDownloadStatus.completed, progress: 1);
    } catch (e) {
      state = VideoDownloadProgress(status: VideoDownloadStatus.failed, error: e.toString());
    }
  }

  Future<void> delete() async {
    final model = HiveSetup.videoDownloadsBox.get(lessonId);
    if (model != null) {
      final file = File(model.localFilePath);
      if (await file.exists()) await file.delete();
      await model.delete();
    }
    state = const VideoDownloadProgress(status: VideoDownloadStatus.idle);
  }
}

/// Every locally-saved video, expired ones cleaned up (file + Hive record)
/// as they're found rather than merely hidden — keeps device storage from
/// silently accumulating stale downloads.
@riverpod
Future<List<DownloadedVideoModel>> localVideoDownloads(LocalVideoDownloadsRef ref) async {
  final box = HiveSetup.videoDownloadsBox;
  final expired = box.values.where((v) => v.isExpired).toList();
  for (final video in expired) {
    final file = File(video.localFilePath);
    if (await file.exists()) await file.delete();
    await video.delete();
  }
  final active = box.values.toList()..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
  return active;
}
