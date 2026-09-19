import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/stale_while_revalidate.dart';
import '../../data/book_api.dart';
import '../../data/models/book_summary.dart';

part 'book_list_controller.g.dart';

/// Family key: category filter + search query — a Dart record gets
/// structural equality for free, so switching either just watches a
/// distinct provider instance with its own pagination state, same pattern
/// as `VideoCoursesController`'s `int?` key.
typedef BookListFilter = ({int? categoryId, String? search});

class BookListState {
  const BookListState({required this.items, required this.hasMore, this.isLoadingMore = false});

  final List<BookSummary> items;
  final bool hasMore;
  final bool isLoadingMore;

  BookListState copyWith({List<BookSummary>? items, bool? hasMore, bool? isLoadingMore}) {
    return BookListState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class BookListController extends _$BookListController {
  int _page = 1;

  @override
  Future<BookListState> build(BookListFilter filter) async {
    _page = 1;
    final api = ref.watch(bookApiProvider);
    final cachedPage = api.readCachedBooks(categoryId: filter.categoryId, search: filter.search);
    return seedAndRevalidate(
      cached: cachedPage == null ? null : BookListState(items: cachedPage.items, hasMore: cachedPage.meta.hasMore),
      fetch: () async {
        final result = await api.listBooks(page: _page, categoryId: filter.categoryId, search: filter.search);
        return BookListState(items: result.items, hasMore: result.meta.hasMore);
      },
      onRevalidated: (v) => state = AsyncData(v),
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref
        .read(bookApiProvider)
        .listBooks(page: _page + 1, categoryId: filter.categoryId, search: filter.search);
    _page += 1;
    state = AsyncData(BookListState(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(bookApiProvider).listBooks(page: 1, categoryId: filter.categoryId, search: filter.search);
      return BookListState(items: result.items, hasMore: result.meta.hasMore);
    });
  }
}
