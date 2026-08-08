/// Mirrors `ProfileService::getUserDetails()` — deliberately distinct from
/// `features/auth/data/models/user_model.dart`'s `UserModel` (that one
/// parses `/auth/*/verify`'s `created_at` key; this endpoint sends the same
/// data under `member_since` instead, and omits a couple of auth-only
/// fields), so reusing `UserModel` here would silently mis-parse.
class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.username,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.referralCode,
    required this.role,
    required this.status,
    required this.isVerified,
    required this.memberSince,
    this.lastLoginAt,
  });

  final int id;
  final String uuid;
  final String firstName;
  final String lastName;
  final String fullName;
  final String username;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? referralCode;
  final String role;
  final String status;
  final bool isVerified;
  final DateTime memberSince;
  final DateTime? lastLoginAt;

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      fullName: json['full_name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      referralCode: json['referral_code'] as String?,
      role: json['role'] as String? ?? 'student',
      status: json['status'] as String? ?? 'active',
      isVerified: json['is_verified'] as bool? ?? false,
      memberSince: DateTime.tryParse(json['member_since'] as String? ?? '') ?? DateTime.now(),
      lastLoginAt: json['last_login_at'] != null ? DateTime.tryParse(json['last_login_at'] as String) : null,
    );
  }
}

class UserStats {
  const UserStats({
    required this.totalExamsTaken,
    required this.totalQuestionsAnswered,
    required this.averageScorePercent,
    required this.bestScorePercent,
    required this.totalStudyTimeMinutes,
    required this.totalStudyTimeLabel,
    required this.videosWatched,
    required this.videosCompleted,
    required this.coursesEnrolled,
    required this.booksRead,
    required this.booksCompleted,
    required this.booksSavedOffline,
    required this.currentStreakDays,
    required this.longestStreakDays,
  });

  final int totalExamsTaken;
  final int totalQuestionsAnswered;
  final double averageScorePercent;
  final double bestScorePercent;
  final int totalStudyTimeMinutes;
  final String totalStudyTimeLabel;
  final int videosWatched;
  final int videosCompleted;
  final int coursesEnrolled;
  final int booksRead;
  final int booksCompleted;
  final int booksSavedOffline;
  final int currentStreakDays;
  final int longestStreakDays;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalExamsTaken: json['total_exams_taken'] as int? ?? 0,
      totalQuestionsAnswered: json['total_questions_answered'] as int? ?? 0,
      averageScorePercent: (json['average_score_percent'] as num?)?.toDouble() ?? 0,
      bestScorePercent: (json['best_score_percent'] as num?)?.toDouble() ?? 0,
      totalStudyTimeMinutes: json['total_study_time_minutes'] as int? ?? 0,
      totalStudyTimeLabel: json['total_study_time_label'] as String? ?? '0m',
      videosWatched: json['videos_watched'] as int? ?? 0,
      videosCompleted: json['videos_completed'] as int? ?? 0,
      coursesEnrolled: json['courses_enrolled'] as int? ?? 0,
      booksRead: json['books_read'] as int? ?? 0,
      booksCompleted: json['books_completed'] as int? ?? 0,
      booksSavedOffline: json['books_saved_offline'] as int? ?? 0,
      currentStreakDays: json['current_streak_days'] as int? ?? 0,
      longestStreakDays: json['longest_streak_days'] as int? ?? 0,
    );
  }
}

class UserPreferences {
  const UserPreferences({
    required this.theme,
    required this.pushNotificationsEnabled,
    required this.emailNotificationsEnabled,
    required this.examRemindersEnabled,
    required this.preferredLanguage,
  });

  /// 'light' | 'dark' | 'system'.
  final String theme;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool examRemindersEnabled;
  final String preferredLanguage;

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] as String? ?? 'system',
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool? ?? true,
      examRemindersEnabled: json['exam_reminders_enabled'] as bool? ?? true,
      preferredLanguage: json['preferred_language'] as String? ?? 'en',
    );
  }
}

class LeaderboardPosition {
  const LeaderboardPosition({
    required this.rank,
    required this.totalScore,
    required this.examsCompleted,
    required this.avgScorePercent,
  });

  final int? rank;
  final num totalScore;
  final int examsCompleted;
  final num avgScorePercent;

  factory LeaderboardPosition.fromJson(Map<String, dynamic> json) {
    return LeaderboardPosition(
      rank: json['rank'] as int?,
      totalScore: json['total_score'] as num? ?? 0,
      examsCompleted: json['exams_completed'] as int? ?? 0,
      avgScorePercent: json['avg_score_percent'] as num? ?? 0,
    );
  }
}

/// `GET /profile`'s aggregate payload.
class FullProfile {
  const FullProfile({required this.user, required this.stats, required this.preferences, required this.leaderboard});

  final ProfileUser user;
  final UserStats stats;
  final UserPreferences preferences;
  final LeaderboardPosition leaderboard;

  factory FullProfile.fromJson(Map<String, dynamic> json) {
    return FullProfile(
      user: ProfileUser.fromJson(json['user'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      preferences: UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
      leaderboard: LeaderboardPosition.fromJson(json['leaderboard'] as Map<String, dynamic>),
    );
  }
}

/// One entry in `GET /profile/purchases` — the backend sends three
/// differently-shaped lists (`exam_types`/`video_courses`/`books`, each
/// with its own image-field name: `image_url`/`thumbnail_url`/`cover_url`),
/// normalized here into one `imageUrl`.
class PurchaseItem {
  const PurchaseItem({
    required this.type,
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    required this.expiresAt,
    required this.daysLeft,
    required this.grantedBy,
  });

  /// 'exam_type' | 'video_course' | 'book'.
  final String type;
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final DateTime expiresAt;
  final int daysLeft;
  final String grantedBy;

  factory PurchaseItem.fromJson(Map<String, dynamic> json, String type) {
    return PurchaseItem(
      type: type,
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      imageUrl: (json['image_url'] ?? json['thumbnail_url'] ?? json['cover_url']) as String?,
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ?? DateTime.now(),
      daysLeft: json['days_left'] as int? ?? 0,
      grantedBy: json['granted_by'] as String? ?? 'payment',
    );
  }
}

class PurchasesSummary {
  const PurchasesSummary({
    required this.examTypes,
    required this.videoCourses,
    required this.books,
    required this.total,
  });

  final List<PurchaseItem> examTypes;
  final List<PurchaseItem> videoCourses;
  final List<PurchaseItem> books;
  final int total;

  factory PurchasesSummary.fromJson(Map<String, dynamic> json) {
    return PurchasesSummary(
      examTypes: (json['exam_types'] as List<dynamic>? ?? [])
          .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>, 'exam_type'))
          .toList(),
      videoCourses: (json['video_courses'] as List<dynamic>? ?? [])
          .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>, 'video_course'))
          .toList(),
      books: (json['books'] as List<dynamic>? ?? [])
          .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>, 'book'))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.uuid,
    required this.gateway,
    required this.contentType,
    required this.contentId,
    required this.contentTitle,
    required this.amount,
    required this.formatted,
    required this.currency,
    required this.status,
    this.paidAt,
    required this.createdAt,
  });

  final int id;
  final String uuid;
  final String gateway;
  final String contentType;
  final int contentId;
  final String contentTitle;
  final double amount;
  final String formatted;
  final String currency;
  final String status;
  final DateTime? paidAt;
  final DateTime createdAt;

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      gateway: json['gateway'] as String,
      contentType: json['content_type'] as String,
      contentId: json['content_id'] as int,
      contentTitle: json['content_title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      formatted: json['formatted'] as String? ?? '',
      currency: json['currency'] as String? ?? 'NGN',
      status: json['status'] as String? ?? 'pending',
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'] as String) : null,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
