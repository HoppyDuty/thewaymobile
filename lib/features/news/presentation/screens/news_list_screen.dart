import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../data/models/news_summary.dart';
import '../providers/news_list_controller.dart';
import '../widgets/news_card.dart';

class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  final _scrollController = ScrollController();

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
      ref.read(newsListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: state.when(
        loading: () => AppShimmer(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 6,
            itemBuilder: (context, index) => const ShimmerListTile(),
          ),
        ),
        error: (error, _) => AppErrorState(
          message: mapErrorToMessage(error),
          onRetry: () => ref.invalidate(newsListControllerProvider),
        ),
        data: (data) {
          if (data.items.isEmpty) {
            return const AppEmptyState(
              title: 'No news yet',
              message: 'Check back soon for updates.',
              icon: AppIcons.news,
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(newsListControllerProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: data.items.length + (data.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= data.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(child: CupertinoActivityIndicator()),
                  );
                }
                final NewsSummary article = data.items[index];
                return NewsCard(news: article);
              },
            ),
          );
        },
      ),
    );
  }
}
