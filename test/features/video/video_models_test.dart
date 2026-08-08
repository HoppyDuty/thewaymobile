import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/video/data/models/video_course_detail.dart';
import 'package:theway_mobile/features/video/data/models/video_course_summary.dart';
import 'package:theway_mobile/features/video/data/models/video_download_models.dart';

void main() {
  group('VideoCourseSummary', () {
    test('parses categories embedded in the /videos list response', () {
      final course = VideoCourseSummary.fromJson({
        'id': 1,
        'title': 'UTME Mathematics Masterclass',
        'slug': 'utme-mathematics-masterclass',
        'price': 5000,
        'video_count': 8,
        'duration': '1h 20m',
        'total_seconds': 4800,
        'categories': [
          {'id': 1, 'name': 'Mathematics', 'slug': 'mathematics', 'color_hex': '#6a1b9a'},
        ],
        'has_access': false,
        'is_free': false,
        'progress_percent': 25,
      });

      expect(course.categories, hasLength(1));
      expect(course.categories.first.name, 'Mathematics');
      expect(course.isFree, isFalse);
      expect(course.progressPercent, 25);
    });

    test('defaults categories to empty when the field is absent', () {
      final course = VideoCourseSummary.fromJson({
        'id': 1,
        'title': 'Free Course',
        'slug': 'free-course',
        'price': 0,
        'video_count': 3,
        'duration': '20m',
        'total_seconds': 1200,
        'has_access': true,
        'is_free': true,
        'progress_percent': 0,
      });

      expect(course.categories, isEmpty);
      expect(course.isFree, isTrue);
    });
  });

  group('VideoCourseDetail', () {
    test('marks lessons beyond the free-preview limit as locked for free users', () {
      final detail = VideoCourseDetail.fromJson({
        'id': 1,
        'title': 'Course',
        'slug': 'course',
        'price': 5000,
        'video_count': 2,
        'duration': '10m',
        'total_seconds': 600,
        'has_access': false,
        'free_preview': 5,
        'lessons': [
          {
            'id': 1, 'youtube_video_id': 'abc', 'title': 'L1', 'duration_seconds': 300,
            'duration_label': '5:00', 'position': 0, 'is_playable': true, 'is_free_preview': true,
            'progress_percent': 0, 'watched_seconds': 0, 'is_completed': false,
          },
          {
            'id': 2, 'youtube_video_id': 'def', 'title': 'L2', 'duration_seconds': 300,
            'duration_label': '5:00', 'position': 6, 'is_playable': false, 'is_free_preview': false,
            'progress_percent': 0, 'watched_seconds': 0, 'is_completed': false,
          },
        ],
      });

      expect(detail.lessons[0].isPlayable, isTrue);
      expect(detail.lessons[1].isPlayable, isFalse);
      expect(detail.hasAccess, isFalse);
    });
  });

  group('DownloadRequestResult', () {
    test('reads days_remaining when returned by an already-completed download', () {
      final result = DownloadRequestResult.fromJson({
        'download_token': 'tok',
        'status': 'completed',
        'expires_at': '2026-08-01T00:00:00Z',
        'days_remaining': 12,
      });

      expect(result.daysRemaining, 12);
    });

    test('falls back to expires_in_days for a brand-new download request', () {
      final result = DownloadRequestResult.fromJson({
        'download_token': 'tok',
        'status': 'pending',
        'expires_at': '2026-08-01T00:00:00Z',
        'expires_in_days': 30,
      });

      expect(result.daysRemaining, 30);
    });
  });
}
