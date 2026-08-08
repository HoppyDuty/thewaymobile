import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../data/book_api.dart';

/// Passed via go_router's `extra` when opening the reader — there's no
/// stable route param shape that covers "read online from a Cloudinary URL"
/// and "read a locally-saved file" uniformly, so the screen resolves which
/// source to actually use itself (see [_PdfReaderScreenState._source]).
class PdfReaderArgs {
  const PdfReaderArgs({required this.bookId, required this.pdfUrl, required this.title, this.initialPage = 1});

  final int bookId;
  final String pdfUrl;
  final String title;
  final int initialPage;
}

/// Renders a book's PDF — `flutter_pdfview` accepts either a local file
/// path or a direct `https://` URL, so this transparently prefers an
/// already-saved-offline copy (see `SavedBookModel`) and falls back to
/// streaming the Cloudinary URL when reading online without having saved it.
class PdfReaderScreen extends ConsumerStatefulWidget {
  const PdfReaderScreen({super.key, required this.args});

  final PdfReaderArgs args;

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen> {
  int _totalPages = 0;
  int _lastSavedPage = 0;

  String get _source {
    final saved = HiveSetup.savedBooksBox.get(widget.args.bookId);
    if (saved != null && !saved.isExpired && File(saved.localFilePath).existsSync()) {
      return saved.localFilePath;
    }
    return widget.args.pdfUrl;
  }

  void _onPageChanged(int? page, int? total) {
    if (page == null) return;
    if (total != null) _totalPages = total;
    final currentPage = page + 1; // flutter_pdfview pages are 0-indexed
    if (currentPage == _lastSavedPage || _totalPages <= 0) return;
    _lastSavedPage = currentPage;
    _saveProgress(currentPage);
  }

  Future<void> _saveProgress(int currentPage) async {
    try {
      await ref
          .read(bookApiProvider)
          .saveProgress(bookId: widget.args.bookId, currentPage: currentPage, totalPages: _totalPages);
    } catch (_) {
      // Best-effort — progress will catch up on the next successful save.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.title)),
      body: PDFView(
        filePath: _source,
        defaultPage: (widget.args.initialPage - 1).clamp(0, 1 << 20),
        swipeHorizontal: false,
        autoSpacing: true,
        pageSnap: true,
        onPageChanged: _onPageChanged,
        onError: (error) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not load PDF: $error'))),
      ),
    );
  }
}
