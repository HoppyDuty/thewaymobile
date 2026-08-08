import '../../../news/data/models/news_summary.dart';
import 'carousel_slide.dart';
import 'continue_learning_item.dart';
import 'greeting.dart';
import 'leaderboard.dart';
import 'recommended_course.dart';

/// The single aggregated `GET /home` payload.
class HomeScreenData {
  const HomeScreenData({
    required this.greeting,
    required this.unreadNotifications,
    required this.carousel,
    required this.continueLearning,
    required this.recommendedCourses,
    required this.leaderboard,
    required this.news,
  });

  final Greeting greeting;
  final int unreadNotifications;
  final List<CarouselSlide> carousel;
  final List<ContinueLearningItem> continueLearning;
  final List<RecommendedCourse> recommendedCourses;
  final Leaderboard leaderboard;
  final List<NewsSummary> news;

  factory HomeScreenData.fromJson(Map<String, dynamic> json) {
    return HomeScreenData(
      greeting: Greeting.fromJson(json['greeting'] as Map<String, dynamic>),
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
      carousel: (json['carousel'] as List<dynamic>? ?? [])
          .map((e) => CarouselSlide.fromJson(e as Map<String, dynamic>))
          .toList(),
      continueLearning: (json['continue_learning'] as List<dynamic>? ?? [])
          .map((e) => ContinueLearningItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendedCourses: (json['recommended_courses'] as List<dynamic>? ?? [])
          .map((e) => RecommendedCourse.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaderboard: Leaderboard.fromJson(json['leaderboard'] as Map<String, dynamic>? ?? {}),
      news: (json['news'] as List<dynamic>? ?? [])
          .map((e) => NewsSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
