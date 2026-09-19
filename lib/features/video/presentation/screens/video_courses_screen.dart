import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/video_course_summary.dart';
import '../providers/video_categories_controller.dart';
import '../providers/video_courses_controller.dart';

/// The Videos tab root — category filter chips (mirrors the book system's
/// category browsing) above an infinite-scroll course list.
class VideoCoursesScreen extends ConsumerStatefulWidget {
  const VideoCoursesScreen({super.key});

  @override
  ConsumerState<VideoCoursesScreen> createState() => _VideoCoursesScreenState();
}

class _VideoCoursesScreenState extends ConsumerState<VideoCoursesScreen> {
  final _scrollController = ScrollController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(videoCoursesControllerProvider(_selectedCategoryId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(videoCategoriesProvider);
    final coursesState = ref.watch(videoCoursesControllerProvider(_selectedCategoryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Courses'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            tooltip: 'My Videos',
            onPressed: () => context.push('/videos/downloads'),
          ),
        ],
      ),
      body: Column(
        children: [
          categoriesState.when(
            loading: () => const SizedBox(height: 48),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) {
              if (categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => setState(() => _selectedCategoryId = null),
                      ),
                    ),
                    for (final category in categories)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.xs),
                        child: ChoiceChip(
                          label: Text('${category.name} (${category.coursesCount})'),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => setState(() => _selectedCategoryId = category.id),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: coursesState.when(
              loading: () => AppShimmer(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: 5,
                  itemBuilder: (context, index) => Container(
                    height: 180,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius),
                  ),
                ),
              ),
              error: (error, _) => AppErrorState(
                message: mapErrorToMessage(error),
                onRetry: () => ref.invalidate(videoCoursesControllerProvider(_selectedCategoryId)),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return const AppEmptyState(
                    title: 'No video courses yet',
                    message: 'Check back soon for new courses.',
                    icon: AppIcons.playOutline,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(videoCoursesControllerProvider(_selectedCategoryId).notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: data.items.length + (data.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= data.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                          child: Center(child: CupertinoActivityIndicator()),
                        );
                      }
                      return _VideoCourseCard(course: data.items[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoCourseCard extends StatelessWidget {
  const _VideoCourseCard({required this.course});

  final VideoCourseSummary course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        onTap: () => context.push('/videos/${course.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: AppNetworkImage(url: course.thumbnailUrl)),
                if (course.progressPercent > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(value: course.progressPercent / 100, minHeight: 4),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.title, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(AppIcons.playOutline, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${course.videoCount} videos · ${course.duration}', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (course.categories.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            children: [
                              for (final category in course.categories.take(2))
                                Chip(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  label: Text(category.name, style: theme.textTheme.labelSmall),
                                ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      Text(
                        course.isFree ? 'Free' : '₦${course.price.toStringAsFixed(0)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: course.isFree ? context.appColors.success : theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
