import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/app_unlock_card.dart';
import '../../../payments/data/models/payment_models.dart';
import '../../../payments/presentation/widgets/payment_sheet.dart';
import '../../data/models/book_detail.dart';
import '../providers/book_detail_controller.dart';
import '../providers/book_download_controller.dart';
import 'pdf_reader_screen.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookDetailControllerProvider(slug));

    return Scaffold(
      body: state.when(
        loading: () => Scaffold(
          appBar: AppBar(),
          body: AppShimmer(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AspectRatio(aspectRatio: 2 / 3, child: Container(color: Colors.white)),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < 4; i++) const ShimmerListTile(),
              ],
            ),
          ),
        ),
        error: (error, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorState(
            message: mapErrorToMessage(error),
            onRetry: () => ref.invalidate(bookDetailControllerProvider(slug)),
          ),
        ),
        data: (book) => _BookDetailBody(book: book, slug: slug),
      ),
    );
  }
}

class _BookDetailBody extends ConsumerWidget {
  const _BookDetailBody({required this.book, required this.slug});

  final BookDetail book;
  final String slug;

  Future<void> _unlock(BuildContext context, WidgetRef ref) async {
    final confirmed = await showPaymentSheet(
      context,
      ref,
      contentType: PaymentContentType.book,
      contentId: book.id,
      contentTitle: book.title,
      price: book.price,
    );
    if (confirmed) {
      ref.invalidate(bookDetailControllerProvider(slug));
    }
  }

  // `book.pdfUrl` is only populated once the backend's PDF-upload job has
  // finished (see BookService::getBookDetail) — it can legitimately be null
  // for a purchased/free book if that job hasn't run yet or silently failed.
  // Previously this force-unwrapped it, crashing uncaught inside onPressed
  // with no visible feedback ("tap Read, nothing happens"). An already
  // downloaded offline copy is still readable even when pdfUrl is null,
  // since the reader checks its local Hive-saved file before ever touching
  // this URL.
  void _read(BuildContext context, {required bool hasOfflineCopy}) {
    if (book.pdfUrl == null && !hasOfflineCopy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This book isn't available to read right now. Please try again shortly.")),
      );
      return;
    }
    context.push(
      '/books/${book.slug}/read',
      extra: PdfReaderArgs(bookId: book.id, pdfUrl: book.pdfUrl ?? '', title: book.title, initialPage: book.progress?.currentPage ?? 1),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final downloadState = ref.watch(bookDownloadControllerProvider(book.id));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.only(top: kToolbarHeight, bottom: AppSpacing.md),
              child: Center(
                child: ClipRRect(
                  borderRadius: AppRadius.mdRadius,
                  child: AppNetworkImage(url: book.coverUrl, width: 140, height: 200, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: theme.textTheme.headlineSmall),
                if (book.author != null) ...[
                  const SizedBox(height: 4),
                  Text('by ${book.author!.name}', style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(AppIcons.book, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${book.pageCount} pages', style: theme.textTheme.bodySmall),
                    if (book.publishedYear != null) ...[
                      const Text(' · '),
                      Text('${book.publishedYear}', style: theme.textTheme.bodySmall),
                    ],
                    if (book.edition != null) ...[
                      const Text(' · '),
                      Text(book.edition!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
                if (book.categories.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [for (final c in book.categories) Chip(label: Text(c.name))],
                  ),
                ],
                if (book.description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(book.description!, style: theme.textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.lg),
                if (!book.hasAccess && !book.isFree)
                  AppUnlockCard(
                    title: 'Unlock This Book — ₦${book.price.toStringAsFixed(0)}',
                    onTap: () => _unlock(context, ref),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: book.progress != null && book.progress!.currentPage > 1 ? 'Continue Reading' : 'Read',
                          icon: AppIcons.book,
                          onPressed: () => _read(
                            context,
                            hasOfflineCopy: downloadState.status == BookDownloadStatus.completed,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _SaveOfflineButton(book: book, state: downloadState),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveOfflineButton extends ConsumerWidget {
  const _SaveOfflineButton({required this.book, required this.state});

  final BookDetail book;
  final BookDownloadProgress state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (state.status) {
      case BookDownloadStatus.completed:
        return const CircleAvatar(child: Icon(AppIcons.downloadDone));
      case BookDownloadStatus.requesting:
        return const SizedBox(
          width: 40,
          height: 40,
          child: Padding(padding: EdgeInsets.all(10), child: CupertinoActivityIndicator()),
        );
      case BookDownloadStatus.downloading:
        return SizedBox(
          width: 40,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: CircularProgressIndicator(strokeWidth: 2, value: state.progress),
          ),
        );
      case BookDownloadStatus.idle:
      case BookDownloadStatus.failed:
        return IconButton.filledTonal(
          icon: const Icon(AppIcons.download),
          tooltip: 'Save offline',
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            await ref.read(bookDownloadControllerProvider(book.id).notifier).start(book);
            final result = ref.read(bookDownloadControllerProvider(book.id));
            if (result.status == BookDownloadStatus.failed) {
              messenger.showSnackBar(SnackBar(content: Text(result.error ?? 'Could not save this book offline.')));
            }
          },
        );
    }
  }
}
