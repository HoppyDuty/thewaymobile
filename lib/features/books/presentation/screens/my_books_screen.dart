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
import '../../data/models/saved_book_model.dart';
import '../providers/book_download_controller.dart';
import 'pdf_reader_screen.dart';

/// "My Books" — PDFs actually saved to local disk, readable with zero
/// connectivity, each good for 30 days (mirrors the server's
/// `BookService::SAVE_EXPIRY_DAYS`) before being cleaned up.
class MyBooksScreen extends ConsumerWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(localSavedBooksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Books')),
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
          onRetry: () => ref.invalidate(localSavedBooksProvider),
        ),
        data: (books) {
          if (books.isEmpty) {
            return const AppEmptyState(
              title: 'No saved books yet',
              message: 'Save a book offline from its detail page to read it without connectivity for up to 30 days.',
              icon: AppIcons.book,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(localSavedBooksProvider);
              await ref.read(localSavedBooksProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: books.length,
              itemBuilder: (context, index) => _SavedBookTile(book: books[index]),
            ),
          );
        },
      ),
    );
  }
}

class _SavedBookTile extends ConsumerWidget {
  const _SavedBookTile({required this.book});

  final SavedBookModel book;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    await ref.read(bookDownloadControllerProvider(book.bookId).notifier).delete();
    ref.invalidate(localSavedBooksProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved book removed.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
        leading: ClipRRect(
          borderRadius: AppRadius.smRadius,
          child: AppNetworkImage(url: book.coverUrl, width: 44, height: 60),
        ),
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${book.authorName ?? 'Unknown author'} · ${book.pageCount} pages · ${_formatBytes(book.fileSizeBytes)} · '
          '${book.daysRemaining} day(s) left',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(AppIcons.delete),
          tooltip: 'Remove',
          onPressed: () => _delete(context, ref),
        ),
        onTap: () => context.push(
          '/books/${book.slug}/read',
          extra: PdfReaderArgs(bookId: book.bookId, pdfUrl: book.localFilePath, title: book.title),
        ),
      ),
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
