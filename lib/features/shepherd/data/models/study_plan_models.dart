class StudyPlanWeek {
  const StudyPlanWeek({
    required this.week,
    required this.theme,
    required this.topics,
    required this.goals,
    required this.dailyTargetMinutes,
    required this.resources,
  });

  final int week;
  final String theme;
  final List<String> topics;
  final List<String> goals;
  final int dailyTargetMinutes;
  final List<String> resources;

  factory StudyPlanWeek.fromJson(Map<String, dynamic> json) {
    return StudyPlanWeek(
      week: json['week'] as int? ?? 0,
      theme: json['theme'] as String? ?? '',
      topics: List<String>.from(json['topics'] as List? ?? []),
      goals: List<String>.from(json['goals'] as List? ?? []),
      dailyTargetMinutes: json['daily_target_minutes'] as int? ?? 60,
      resources: List<String>.from(json['resources'] as List? ?? []),
    );
  }
}

class StudyPlan {
  const StudyPlan({
    required this.uuid,
    required this.examDate,
    required this.weeksRemaining,
    required this.examType,
    required this.weeklyPlan,
    required this.isActive,
    required this.createdAt,
  });

  final String uuid;

  /// Pre-formatted by the backend (`d M Y`), not ISO — displayed as-is.
  final String examDate;
  final int weeksRemaining;
  final String examType;
  final List<StudyPlanWeek> weeklyPlan;
  final bool isActive;
  final DateTime createdAt;

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      uuid: json['uuid'] as String,
      examDate: json['exam_date'] as String,
      weeksRemaining: json['weeks_remaining'] as int? ?? 0,
      examType: json['exam_type'] as String? ?? 'General',
      weeklyPlan: (json['weekly_plan'] as List<dynamic>? ?? [])
          .map((w) => StudyPlanWeek.fromJson(w as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
