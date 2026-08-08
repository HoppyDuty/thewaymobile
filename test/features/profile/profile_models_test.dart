import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/profile/data/models/profile_models.dart';

void main() {
  group('ProfileUser', () {
    test('parses member_since (not created_at) as the join-date field', () {
      final user = ProfileUser.fromJson({
        'id': 1,
        'uuid': 'abc-123',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'full_name': 'Ada Lovelace',
        'username': 'ada',
        'email': 'ada@example.com',
        'role': 'student',
        'status': 'active',
        'is_verified': true,
        'member_since': '2026-01-01T00:00:00Z',
      });

      expect(user.memberSince.year, 2026);
      expect(user.isVerified, isTrue);
    });
  });

  group('PurchaseItem', () {
    test('normalizes the differently-named image field per content type', () {
      final examAccess = PurchaseItem.fromJson({
        'id': 1, 'name': 'UTME', 'slug': 'utme', 'image_url': 'a.png', 'expires_at': '2026-08-01T00:00:00Z',
        'days_left': 10, 'granted_by': 'payment',
      }, 'exam_type');
      final courseAccess = PurchaseItem.fromJson({
        'id': 2, 'name': 'Course', 'slug': 'course', 'thumbnail_url': 'b.png', 'expires_at': '2026-08-01T00:00:00Z',
        'days_left': 5, 'granted_by': 'payment',
      }, 'video_course');
      final bookAccess = PurchaseItem.fromJson({
        'id': 3, 'name': 'Book', 'slug': 'book', 'cover_url': 'c.png', 'expires_at': '2026-08-01T00:00:00Z',
        'days_left': 20, 'granted_by': 'admin',
      }, 'book');

      expect(examAccess.imageUrl, 'a.png');
      expect(courseAccess.imageUrl, 'b.png');
      expect(bookAccess.imageUrl, 'c.png');
      expect(bookAccess.grantedBy, 'admin');
    });
  });

  group('PurchasesSummary', () {
    test('groups purchases into their three content-type buckets', () {
      final summary = PurchasesSummary.fromJson({
        'exam_types': [
          {'id': 1, 'name': 'UTME', 'slug': 'utme', 'expires_at': '2026-08-01T00:00:00Z', 'days_left': 10, 'granted_by': 'payment'},
        ],
        'video_courses': [],
        'books': [],
        'total': 1,
      });

      expect(summary.examTypes, hasLength(1));
      expect(summary.videoCourses, isEmpty);
      expect(summary.total, 1);
    });
  });
}
