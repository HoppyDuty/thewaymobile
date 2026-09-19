import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/home/data/models/home_screen.dart';

void main() {
  group('HomeScreenData', () {
    test('parses the full /home aggregate payload', () {
      final data = HomeScreenData.fromJson({
        'greeting': {
          'greeting': 'Good morning',
          'name': 'Ada',
          'full_name': 'Ada Lovelace',
          'avatar_url': null,
        },
        'unread_notifications': 3,
        'carousel': [
          {'id': 1, 'title': 'Welcome', 'subtitle': null, 'image_url': 'https://x.com/a.png', 'link_type': 'none'},
        ],
        'continue_learning': [
          {
            'id': 1,
            'entity_type': 'cbt_session',
            'entity_id': 10,
            'title': 'UTME Practice',
            'thumbnail': null,
            'progress_percent': 40,
            'last_accessed_at': '2026-01-01T10:00:00Z',
          },
        ],
        'recommended_courses': [
          {'id': 5, 'title': 'Physics Masterclass', 'slug': 'physics-masterclass', 'thumbnail_url': null, 'price': 2000, 'description': null},
        ],
        'leaderboard': {
          'top': [
            {
              'rank': 1,
              'total_score': 950,
              'exams_completed': 12,
              'avg_score_percent': 88.5,
              'user': {'id': 2, 'name': 'Bola', 'username': 'bola', 'avatar_url': null},
            },
          ],
          'my_entry': null,
        },
        'news': [
          {
            'id': 1,
            'title': 'JAMB Update',
            'slug': 'jamb-update',
            'excerpt': 'Something happened',
            'thumbnail': null,
            'likes_count': 5,
            'comments_count': 2,
            'views_count': 100,
            'is_liked': true,
            'published_at': '2026-01-01T09:00:00Z',
          },
        ],
      });

      expect(data.greeting.name, 'Ada');
      expect(data.unreadNotifications, 3);
      expect(data.carousel, hasLength(1));
      expect(data.continueLearning.single.entityType, 'cbt_session');
      expect(data.recommendedCourses.single.price, 2000);
      expect(data.leaderboard.top.single.user?.name, 'Bola');
      expect(data.leaderboard.myEntry, isNull);
      expect(data.news.single.isLiked, isTrue);
    });

    test('tolerates missing optional sections', () {
      final data = HomeScreenData.fromJson({
        'greeting': {'greeting': 'Good evening', 'name': 'A', 'full_name': 'A B'},
        'unread_notifications': 0,
      });

      expect(data.carousel, isEmpty);
      expect(data.continueLearning, isEmpty);
      expect(data.leaderboard.top, isEmpty);
      expect(data.news, isEmpty);
    });
  });
}
