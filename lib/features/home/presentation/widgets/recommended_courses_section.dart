import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../data/models/recommended_course.dart';

class RecommendedCoursesSection extends StatelessWidget {
  const RecommendedCoursesSection({super.key, required this.courses});

  final List<RecommendedCourse> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: 'Recommended For You', onViewAll: () => context.push('/videos')),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final course = courses[index];
              return SizedBox(
                width: 160,
                child: InkWell(
                  borderRadius: AppRadius.mdRadius,
                  onTap: () => context.push('/videos/${course.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppNetworkImage(
                        url: course.thumbnailUrl,
                        width: 160,
                        height: 90,
                        borderRadius: AppRadius.mdRadius,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(course.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        course.price == 0 ? 'Free' : '₦${course.price.toStringAsFixed(0)}',
                        style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
