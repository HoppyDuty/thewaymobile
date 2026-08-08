import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../data/book_api.dart';
import '../../data/models/book_detail.dart';
import '../../data/models/saved_book_model.dart';

part 'book_download_controller.g.dart';

enum BookDownloadStatus { idle, requesting, downloading, completed, failed }

class BookDownloadProgress {
  const BookDownloadProgress({required this.status, this.progress = 0, this.error});

  final BookDownloadStatus status;

  /// 0.0–1.0, only meaningful while [status] is [BookDownloadStatus.downloading].
  final double progress;
  final String? error;

  bool get isActive => status == BookDownloadStatus.requesting || status == BookDownloadStatus.downloading;
}

/// Saves a book's PDF for fully offline reading. Simpler than the video
/// equivalent (`VideoDownloadController`) since `POST /books/{id}/save-offline`
/// returns a directly-fetchable Cloudinary URL immediately — no server-side
/// processing job to poll for, just a straight file download.
@riverpod
class BookDownloadController extends _$BookDownloadController {
  @override
  BookDownloadProgress build(int bookId) {
    final existing = HiveSetup.savedBooksBox.get(bookId);
    if (existing != null && !existing.isExpired) {
      return const BookDownloadProgress(status: BookDownloadStatus.completed, progress: 1);
    }
    return const BookDownloadProgress(status: BookDownloadStatus.idle);
  }

  Future<void> start(BookDetail book) async {
    if (state.isActive) return;

    state = const BookDownloadProgress(status: BookDownloadStatus.requesting);
    try {
      final result = await ref.read(bookApiProvider).saveOffline(book.id);

      state = const BookDownloadProgress(status: BookDownloadStatus.downloading, progress: 0);

      final docsDir = await getApplicationDocumentsDirectory();
      final bookDir = Directory('${docsDir.path}/book_downloads');
      if (!await bookDir.exists()) await bookDir.create(recursive: true);
      final localPath = '${bookDir.path}/${book.id}.pdf';

      // A dedicated Dio instance — this fetches a Cloudinary CDN URL, not
      // our own API, so it deliberately skips the auth/device-header
      // interceptors `ApiClient.dio` attaches to every request.
      await Dio().download(
        result.pdfUrl,
        localPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = BookDownloadProgress(status: BookDownloadStatus.downloading, progress: received / total);
          }
        },
      );

      final file = File(localPath);
      final fileSize = await file.length();
      final expiresAtMs = DateTime.tryParse(result.expiresAt)?.millisecondsSinceEpoch;

      final model = SavedBookModel(
        bookId: book.id,
        slug: book.slug,
        title: book.title,
        coverUrl: book.coverUrl,
        authorName: book.author?.name,
        pageCount: book.pageCount,
        localFilePath: localPath,
        fileSizeBytes: fileSize,
        savedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        expiresAt: expiresAtMs != null
            ? expiresAtMs ~/ 1000
            : (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 30 * 86400,
      );
      await HiveSetup.savedBooksBox.put(book.id, model);

      state = const BookDownloadProgress(status: BookDownloadStatus.completed, progress: 1);
    } catch (e) {
      state = BookDownloadProgress(status: BookDownloadStatus.failed, error: e.toString());
    }
  }

  Future<void> delete() async {
    final model = HiveSetup.savedBooksBox.get(bookId);
    if (model != null) {
      final file = File(model.localFilePath);
      if (await file.exists()) await file.delete();
      await model.delete();
    }
    state = const BookDownloadProgress(status: BookDownloadStatus.idle);
  }
}

/// Every locally-saved book, expired ones cleaned up (file + Hive record)
/// as they're found rather than merely hidden.
@riverpod
Future<List<SavedBookModel>> localSavedBooks(LocalSavedBooksRef ref) async {
  final box = HiveSetup.savedBooksBox;
  final expired = box.values.where((v) => v.isExpired).toList();
  for (final book in expired) {
    final file = File(book.localFilePath);
    if (await file.exists()) await file.delete();
    await book.delete();
  }
  final active = box.values.toList()..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  return active;
}
