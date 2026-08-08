import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/news_summary.dart';
import '../../data/news_api.dart';

part 'news_list_controller.g.dart';

class NewsListState {
  const NewsListState({required this.items, required this.hasMore, this.isLoadingMore = false});

  final List<NewsSummary> items;
  final bool hasMore;
  final bool isLoadingMore;

  NewsListState copyWith({List<NewsSummary>? items, bool? hasMore, bool? isLoadingMore}) {
    return NewsListState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class NewsListController extends _$NewsListController {
  int _page = 1;

  @override
  Future<NewsListState> build() async {
    _page = 1;
    final result = await ref.watch(newsApiProvider).list(page: _page);
    return NewsListState(items: result.items, hasMore: result.meta.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(newsApiProvider).list(page: _page + 1);
    _page += 1;
    state = AsyncData(NewsListState(
      items: [...current.items, ...result.items],
      hasMore: result.meta.hasMore,
    ));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(newsApiProvider).list(page: 1);
      return NewsListState(items: result.items, hasMore: result.meta.hasMore);
    });
  }
}
