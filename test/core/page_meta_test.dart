import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/core/network/page_meta.dart';

void main() {
  group('PageMeta', () {
    test('parses a full pagination meta object', () {
      final meta = PageMeta.fromJson({
        'current_page': 2,
        'last_page': 5,
        'per_page': 15,
        'total': 68,
        'has_more': true,
      });

      expect(meta.currentPage, 2);
      expect(meta.hasMore, isTrue);
    });

    test('defaults sensibly when null (non-paginated response)', () {
      final meta = PageMeta.fromJson(null);
      expect(meta.currentPage, 1);
      expect(meta.hasMore, isFalse);
    });
  });
}
