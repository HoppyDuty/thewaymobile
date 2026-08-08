import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/downloaded_video_model.dart';
import '../providers/video_download_controller.dart';
import 'local_video_player_screen.dart';

/// "My Videos" — lessons actually saved to local disk, playable with zero
/// connectivity, each good for 30 days (mirrors the server's
/// `VideoService::DOWNLOAD_EXPIRY_DAYS`) before being cleaned up.
class VideoDownloadsScreen extends ConsumerWidget {
  const VideoDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(localVideoDownloadsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Videos')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(localVideoDownloadsProvider),
        ),
        data: (downloads) {
          if (downloads.isEmpty) {
            return const AppEmptyState(
              title: 'No downloads yet',
              message: 'Download a lesson from a video course to watch it offline for up to 30 days.',
              icon: Icons.download_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(localVideoDownloadsProvider);
              await ref.read(localVideoDownloadsProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: downloads.length,
              itemBuilder: (context, index) => _DownloadTile(video: downloads[index]),
            ),
          );
        },
      ),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.video});

  final DownloadedVideoModel video;

  String get _durationLabel {
    final duration = Duration(seconds: video.durationSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    await ref.read(videoDownloadControllerProvider(video.lessonId).notifier).delete();
    ref.invalidate(localVideoDownloadsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download removed.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        leading: ClipRRect(
          borderRadius: AppRadius.smRadius,
          child: AppNetworkImage(url: video.thumbnailUrl, width: 56, height: 42),
        ),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '$_durationLabel · ${video.quality} · ${_formatBytes(video.fileSizeBytes)} · '
          '${video.daysRemaining} day(s) left',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Remove download',
          onPressed: () => _delete(context, ref),
        ),
        onTap: () => context.push(
          '/videos/local-player',
          extra: LocalVideoPlayerArgs(filePath: video.localFilePath, title: video.title),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
