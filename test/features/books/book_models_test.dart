import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/books/data/models/book_detail.dart';
import 'package:theway_mobile/features/books/data/models/book_summary.dart';
import 'package:theway_mobile/features/books/presentation/providers/book_list_controller.dart';

void main() {
  group('BookSummary', () {
    test('parses author and categories embedded in the /books list response', () {
      final book = BookSummary.fromJson({
        'id': 1,
        'title': 'The Way Complete UTME Mathematics Guide 2025',
        'slug': 'the-way-complete-utme-mathematics-guide-2025',
        'page_count': 480,
        'price': 3500,
        'file_size_bytes': 1024,
        'language': 'en',
        'reads_count': 10,
        'downloads_count': 2,
        'author': {'id': 1, 'name': 'Prof. Adebayo Okonkwo', 'slug': 'prof-adebayo-okonkwo'},
        'categories': [
          {'id': 1, 'name': 'Mathematics', 'slug': 'mathematics', 'color_hex': '#6a1b9a'},
        ],
        'has_access': false,
        'is_free': false,
        'progress_percent': 0,
        'current_page': 1,
        'is_completed': false,
      });

      expect(book.author?.name, 'Prof. Adebayo Okonkwo');
      expect(book.categories, hasLength(1));
      expect(book.isFree, isFalse);
    });

    test('defaults author/categories when absent (matches nullable author_id in the schema)', () {
      final book = BookSummary.fromJson({
        'id': 2,
        'title': 'Untitled',
        'slug': 'untitled',
        'page_count': 0,
        'price': 0,
        'file_size_bytes': 0,
        'language': 'en',
        'reads_count': 0,
        'downloads_count': 0,
        'has_access': true,
        'is_free': true,
        'progress_percent': 0,
        'current_page': 1,
        'is_completed': false,
      });

      expect(book.author, isNull);
      expect(book.categories, isEmpty);
    });
  });

  group('BookDetail', () {
    test('pdf_url and progress are only present for a paid/accessing user', () {
      final unpaid = BookDetail.fromJson({
        'id': 1,
        'title': 'Book',
        'slug': 'book',
        'page_count': 100,
        'price': 3500,
        'language': 'en',
        'reads_count': 0,
        'downloads_count': 0,
        'has_access': false,
        'is_free': false,
      });

      expect(unpaid.pdfUrl, isNull);
      expect(unpaid.progress, isNull);
      expect(unpaid.offlineSave, isNull);

      final paid = BookDetail.fromJson({
        'id': 1,
        'title': 'Book',
        'slug': 'book',
        'page_count': 100,
        'price': 3500,
        'language': 'en',
        'reads_count': 0,
        'downloads_count': 0,
        'has_access': true,
        'is_free': false,
        'pdf_url': 'https://res.cloudinary.com/example/book.pdf',
        'progress': {
          'current_page': 12,
          'total_pages': 100,
          'progress_percent': 12,
          'is_completed': false,
          'is_saved_offline': true,
          'last_read_at': '2026-07-01T00:00:00Z',
        },
        'offline_save': {'save_token': 'tok', 'expires_at': '2026-08-01T00:00:00Z', 'days_remaining': 25},
      });

      expect(paid.pdfUrl, 'https://res.cloudinary.com/example/book.pdf');
      expect(paid.progress?.currentPage, 12);
      expect(paid.progress?.isSavedOffline, isTrue);
      expect(paid.offlineSave?.daysRemaining, 25);
    });
  });

  group('BookListFilter', () {
    test('two filters with the same category/search are structurally equal (Riverpod family key)', () {
      const BookListFilter a = (categoryId: 1, search: 'utme');
      const BookListFilter b = (categoryId: 1, search: 'utme');
      const BookListFilter c = (categoryId: 2, search: 'utme');

      expect(a, equals(b));
      expect(a == c, isFalse);
    });
  });
}
