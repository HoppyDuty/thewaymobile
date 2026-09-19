import 'dart:async';

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
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/book_summary.dart';
import '../providers/book_categories_controller.dart';
import '../providers/book_list_controller.dart';

/// The Books tab root — search + category filter chips (mirrors both the
/// video system's category browsing and the book system's own admin-side
/// category model) above an infinite-scroll grid.
class BooksListScreen extends ConsumerStatefulWidget {
  const BooksListScreen({super.key});

  @override
  ConsumerState<BooksListScreen> createState() => _BooksListScreenState();
}

class _BooksListScreenState extends ConsumerState<BooksListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  int? _selectedCategoryId;
  String? _search;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(bookListControllerProvider(_filter).notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _search = value.trim().isEmpty ? null : value.trim());
    });
  }

  BookListFilter get _filter => (categoryId: _selectedCategoryId, search: _search);

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(bookCategoriesProvider);
    final listState = ref.watch(bookListControllerProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.download),
            tooltip: 'My Books',
            onPressed: () => context.push('/books/saved'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: AppTextField(
              label: 'Search books',
              controller: _searchController,
              onChanged: _onSearchChanged,
              suffixIcon: const Icon(AppIcons.search),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
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
                          label: Text('${category.name} (${category.booksCount})'),
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
            child: listState.when(
              loading: () => AppShimmer(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.6,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                      Container(decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius)),
                ),
              ),
              error: (error, _) => AppErrorState(
                message: mapErrorToMessage(error),
                onRetry: () => ref.invalidate(bookListControllerProvider(_filter)),
              ),
              data: (data) {
                if (data.items.isEmpty) {
                  return const AppEmptyState(
                    title: 'No books found',
                    message: 'Try a different search or category.',
                    icon: AppIcons.book,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(bookListControllerProvider(_filter).notifier).refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: data.items.length + (data.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= data.items.length) {
                        return const Center(child: CupertinoActivityIndicator());
                      }
                      return _BookCard(book: data.items[index]);
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

class _BookCard extends StatelessWidget {
  const _BookCard({required this.book});

  final BookSummary book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      child: InkWell(
        onTap: () => context.push('/books/${book.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(url: book.coverUrl),
                  if (book.progressPercent > 0)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: LinearProgressIndicator(value: book.progressPercent / 100, minHeight: 4),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (book.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author!.name,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    book.isFree ? 'Free' : '₦${book.price.toStringAsFixed(0)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: book.isFree ? context.appColors.success : theme.colorScheme.secondary,
                    ),
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
