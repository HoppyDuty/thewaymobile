import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/news/data/models/news_article_detail.dart';
import 'package:theway_mobile/features/news/data/models/news_comment.dart';
import 'package:theway_mobile/features/news/data/models/news_summary.dart';

void main() {
  group('NewsSummary', () {
    test('is_liked is nullable (absent from the paginated /news list)', () {
      final summary = NewsSummary.fromJson({
        'id': 1,
        'title': 'Title',
        'slug': 'title',
        'likes_count': 0,
        'comments_count': 0,
        'views_count': 0,
        'published_at': '2026-01-01T00:00:00Z',
      });

      expect(summary.isLiked, isNull);
    });
  });

  group('NewsArticleDetail', () {
    test('copyWith updates like state without touching other fields', () {
      final article = NewsArticleDetail.fromJson({
        'id': 1,
        'title': 'T',
        'slug': 't',
        'content': '<p>body</p>',
        'likes_count': 4,
        'comments_count': 0,
        'views_count': 10,
        'published_at': '2026-01-01T00:00:00Z',
        'author': {'id': 1, 'name': 'Admin'},
        'is_liked': false,
      });

      final liked = article.copyWith(isLiked: true, likesCount: 5);

      expect(liked.isLiked, isTrue);
      expect(liked.likesCount, 5);
      expect(liked.title, article.title);
    });
  });

  group('NewsComment', () {
    test('parses nested replies', () {
      final comment = NewsComment.fromJson({
        'id': 1,
        'body': 'Nice article',
        'created_at': '2026-01-01T00:00:00Z',
        'user': {'id': 1, 'name': 'A'},
        'replies': [
          {
            'id': 2,
            'body': 'Agreed',
            'created_at': '2026-01-01T00:05:00Z',
            'user': {'id': 2, 'name': 'B'},
          },
        ],
      });

      expect(comment.replies, hasLength(1));
      expect(comment.replies.single.body, 'Agreed');
    });
  });
}
