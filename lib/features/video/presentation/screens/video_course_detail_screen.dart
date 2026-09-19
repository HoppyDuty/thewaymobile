import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_unlock_card.dart';
import '../../../payments/data/models/payment_models.dart';
import '../../../payments/presentation/widgets/payment_sheet.dart';
import '../../data/models/video_course_detail.dart';
import '../../data/models/video_lesson.dart';
import '../providers/video_download_controller.dart';
import '../providers/video_course_detail_controller.dart';

class VideoCourseDetailScreen extends ConsumerWidget {
  const VideoCourseDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCourseDetailControllerProvider(slug));

    return Scaffold(
      body: state.when(
        loading: () => Scaffold(
          appBar: AppBar(),
          body: AppShimmer(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: Container(color: Colors.white)),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < 6; i++) const ShimmerListTile(),
              ],
            ),
          ),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorState(
            message: mapErrorToMessage(error),
            onRetry: () => ref.invalidate(videoCourseDetailControllerProvider(slug)),
          ),
        ),
        data: (course) => _CourseDetailBody(course: course, slug: slug),
      ),
    );
  }
}

class _CourseDetailBody extends ConsumerWidget {
  const _CourseDetailBody({required this.course, required this.slug});

  final VideoCourseDetail course;
  final String slug;

  Future<void> _unlock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showPaymentSheet(
      context,
      ref,
      contentType: PaymentContentType.videoCourse,
      contentId: course.id,
      contentTitle: course.title,
      price: course.price,
    );
    if (confirmed) {
      ref.invalidate(videoCourseDetailControllerProvider(slug));
    }
  }

  void _onLessonTap(BuildContext context, WidgetRef ref, VideoLesson lesson) {
    if (!lesson.isPlayable) {
      _unlock(context, ref);
      return;
    }
    context.push('/videos/${course.slug}/lessons/${lesson.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: AppNetworkImage(url: course.thumbnailUrl),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(AppIcons.playOutline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${course.videoCount} videos · ${course.duration}', style: theme.textTheme.bodyMedium),
                  ],
                ),
                if (course.categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [for (final c in course.categories) Chip(label: Text(c.name))],
                  ),
                ],
                if (course.description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(course.description!, style: theme.textTheme.bodyMedium),
                ],
                if (!course.hasAccess && !course.isFree) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppUnlockCard(
                    title: 'Unlock Full Course — ₦${course.price.toStringAsFixed(0)}',
                    subtitle: 'Free preview: first ${course.freePreviewCount} lessons.',
                    onTap: () => _unlock(context, ref),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text('Lessons', style: theme.textTheme.titleMedium),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: course.lessons.length,
          itemBuilder: (context, index) => _LessonTile(
            lesson: course.lessons[index],
            index: index,
            courseId: course.id,
            courseSlug: course.slug,
            onTap: () => _onLessonTap(context, ref, course.lessons[index]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }
}

class _LessonTile extends ConsumerWidget {
  const _LessonTile({
    required this.lesson,
    required this.index,
    required this.courseId,
    required this.courseSlug,
    required this.onTap,
  });

  final VideoLesson lesson;
  final int index;
  final int courseId;
  final String courseSlug;
  final VoidCallback onTap;

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(videoDownloadControllerProvider(lesson.id).notifier)
          .start(lesson: lesson, courseId: courseId, courseSlug: courseSlug);
      final progress = ref.read(videoDownloadControllerProvider(lesson.id));
      if (progress.status == VideoDownloadStatus.failed) {
        messenger.showSnackBar(SnackBar(content: Text(progress.error ?? 'Download failed.')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(mapErrorToMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final downloadState = ref.watch(videoDownloadControllerProvider(lesson.id));

    return ListTile(
      onTap: onTap,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: AppRadius.smRadius,
            child: AppNetworkImage(url: lesson.thumbnailUrl, width: 64, height: 48),
          ),
          if (!lesson.isPlayable)
            Container(
              width: 64,
              height: 48,
              decoration: BoxDecoration(color: Colors.black45, borderRadius: AppRadius.smRadius),
              child: const Icon(AppIcons.lock, color: Colors.white, size: 18),
            )
          else if (lesson.isCompleted)
            const Icon(AppIcons.success, color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
        ],
      ),
      title: Text('${index + 1}. ${lesson.title}', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: lesson.progressPercent > 0 && lesson.progressPercent < 100
          ? LinearProgressIndicator(value: lesson.progressPercent / 100, minHeight: 3)
          : Text(lesson.durationLabel, style: theme.textTheme.bodySmall),
      trailing: lesson.isPlayable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DownloadButton(state: downloadState, onPressed: () => _download(context, ref)),
                const Icon(AppIcons.play),
              ],
            )
          : null,
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.state, required this.onPressed});

  final VideoDownloadProgress state;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case VideoDownloadStatus.completed:
        return Icon(AppIcons.downloadDone, color: Theme.of(context).colorScheme.primary);
      case VideoDownloadStatus.queued:
      case VideoDownloadStatus.processingOnServer:
        return const SizedBox(
          width: 24,
          height: 24,
          child: Padding(padding: EdgeInsets.all(2), child: CupertinoActivityIndicator()),
        );
      case VideoDownloadStatus.downloadingToDevice:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, value: state.progress),
        );
      case VideoDownloadStatus.idle:
      case VideoDownloadStatus.failed:
        return IconButton(
          icon: const Icon(AppIcons.download),
          tooltip: 'Download',
          onPressed: onPressed,
        );
    }
  }
}
