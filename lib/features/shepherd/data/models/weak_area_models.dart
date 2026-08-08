class WeakSubject {
  const WeakSubject({
    required this.subjectId,
    required this.subjectName,
    required this.avgScore,
    required this.attemptCount,
    required this.isWeak,
  });

  final int subjectId;
  final String subjectName;
  final double avgScore;
  final int attemptCount;
  final bool isWeak;

  factory WeakSubject.fromJson(Map<String, dynamic> json) {
    return WeakSubject(
      subjectId: json['subject_id'] as int,
      subjectName: json['subject_name'] as String,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0,
      attemptCount: json['attempt_count'] as int? ?? 0,
      isWeak: json['is_weak'] as bool? ?? false,
    );
  }
}

class StudyRecommendation {
  const StudyRecommendation({
    required this.priority,
    required this.subject,
    required this.action,
    required this.resource,
  });

  final int priority;
  final String subject;
  final String action;
  final String resource;

  factory StudyRecommendation.fromJson(Map<String, dynamic> json) {
    return StudyRecommendation(
      priority: json['priority'] as int? ?? 0,
      subject: json['subject'] as String? ?? '',
      action: json['action'] as String? ?? '',
      resource: json['resource'] as String? ?? '',
    );
  }
}

class WeakAreaAnalysis {
  const WeakAreaAnalysis({
    required this.narrative,
    required this.weakSubjects,
    required this.recommendations,
    required this.fromCache,
    this.nextAllowedAt,
  });

  final String narrative;
  final List<WeakSubject> weakSubjects;
  final List<StudyRecommendation> recommendations;
  final bool fromCache;
  final DateTime? nextAllowedAt;

  factory WeakAreaAnalysis.fromJson(Map<String, dynamic> json) {
    return WeakAreaAnalysis(
      narrative: json['narrative'] as String? ?? '',
      weakSubjects: (json['weak_subjects'] as List<dynamic>? ?? [])
          .map((s) => WeakSubject.fromJson(s as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((r) => StudyRecommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      fromCache: json['from_cache'] as bool? ?? false,
      nextAllowedAt: json['next_allowed_at'] != null ? DateTime.tryParse(json['next_allowed_at'] as String) : null,
    );
  }
}
