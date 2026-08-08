import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../news/data/models/news_summary.dart';
import '../../../news/presentation/widgets/news_card.dart';

class NewsPreviewSection extends StatelessWidget {
  const NewsPreviewSection({super.key, required this.news});

  final List<NewsSummary> news;

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: 'News', onViewAll: () => context.push('/news')),
        const SizedBox(height: AppSpacing.xs),
        for (final article in news) NewsCard(news: article),
      ],
    );
  }
}
