import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/profile_models.dart';
import '../providers/purchases_controller.dart';

class PurchasesScreen extends ConsumerWidget {
  const PurchasesScreen({super.key});

  static const _typeRoutes = {'exam_type': '/cbt', 'video_course': '/videos', 'book': '/books'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(purchasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Purchases')),
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
          onRetry: () => ref.invalidate(purchasesProvider),
        ),
        data: (summary) {
          if (summary.total == 0) {
            return const AppEmptyState(
              title: 'No purchases yet',
              message: 'Exam access, video courses, and books you buy will appear here.',
              icon: AppIcons.bag,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (summary.examTypes.isNotEmpty) _Section(title: 'Exam Access', items: summary.examTypes),
              if (summary.videoCourses.isNotEmpty) _Section(title: 'Video Courses', items: summary.videoCourses),
              if (summary.books.isNotEmpty) _Section(title: 'Books', items: summary.books),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items});

  final String title;
  final List<PurchaseItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        for (final item in items)
          Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
              leading: ClipRRect(
                borderRadius: AppRadius.smRadius,
                child: AppNetworkImage(url: item.imageUrl, width: 44, height: 44),
              ),
              title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                item.daysLeft > 0 ? '${item.daysLeft} day(s) left' : 'Expired',
                style: theme.textTheme.bodySmall,
              ),
              trailing: const Icon(AppIcons.chevronRight),
              onTap: () => context.push(PurchasesScreen._typeRoutes[item.type] ?? '/home'),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
