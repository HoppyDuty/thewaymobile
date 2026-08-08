import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'exam_type_model.g.dart';

/// Lightweight subject reference embedded directly in the exam-type sync
/// payload (`{id, name, slug, is_english}` — full topic data lives on
/// [SubjectModel] via the separate `/cbt/subjects` sync).
@HiveType(typeId: kHiveTypeExamType + 100)
class ExamTypeSubjectRef {
  ExamTypeSubjectRef({required this.id, required this.name, required this.slug, required this.isEnglish});

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String slug;
  @HiveField(3)
  final bool isEnglish;

  factory ExamTypeSubjectRef.fromJson(Map<String, dynamic> json) {
    return ExamTypeSubjectRef(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      isEnglish: json['is_english'] as bool? ?? false,
    );
  }
}

@HiveType(typeId: kHiveTypeExamType)
class ExamTypeModel {
  ExamTypeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.price,
    required this.maxScorePerSubject,
    required this.hasAggregateMax,
    this.aggregateMaxScore,
    required this.standardDurationMinutes,
    required this.englishQuestionCount,
    required this.otherSubjectQuestionCount,
    required this.minSubjects,
    required this.maxSubjects,
    required this.englishCompulsory,
    required this.hasTheory,
    required this.hasPractical,
    required this.hasComprehension,
    required this.hasRegister,
    required this.hasLiterature,
    required this.showsPercentageAverage,
    this.subjects = const [],
  });

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String slug;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? imageUrl;
  @HiveField(5)
  final double price;
  @HiveField(6)
  final num maxScorePerSubject;
  @HiveField(7)
  final bool hasAggregateMax;
  @HiveField(8)
  final num? aggregateMaxScore;
  @HiveField(9)
  final int standardDurationMinutes;
  @HiveField(10)
  final int englishQuestionCount;
  @HiveField(11)
  final int otherSubjectQuestionCount;
  @HiveField(12)
  final int minSubjects;
  @HiveField(13)
  final int maxSubjects;
  @HiveField(14)
  final bool englishCompulsory;
  @HiveField(15)
  final bool hasTheory;
  @HiveField(16)
  final bool hasPractical;
  @HiveField(17)
  final bool hasComprehension;
  @HiveField(18)
  final bool hasRegister;
  @HiveField(19)
  final bool hasLiterature;
  @HiveField(20)
  final bool showsPercentageAverage;
  @HiveField(21)
  final List<ExamTypeSubjectRef> subjects;

  /// Total max score, used for UTME-style raw scoring (`max_score_per_subject`
  /// × number of subjects), matching `ScoringService`'s formula on the backend.
  num get totalMaxScore =>
      hasAggregateMax ? (aggregateMaxScore ?? maxScorePerSubject * maxSubjects) : maxScorePerSubject * maxSubjects;

  factory ExamTypeModel.fromJson(Map<String, dynamic> json) {
    return ExamTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      maxScorePerSubject: json['max_score_per_subject'] as num? ?? 100,
      hasAggregateMax: json['has_aggregate_max'] as bool? ?? false,
      aggregateMaxScore: json['aggregate_max_score'] as num?,
      standardDurationMinutes: json['standard_duration_minutes'] as int? ?? 120,
      englishQuestionCount: json['english_question_count'] as int? ?? 0,
      otherSubjectQuestionCount: json['other_subject_question_count'] as int? ?? 0,
      minSubjects: json['min_subjects'] as int? ?? 4,
      maxSubjects: json['max_subjects'] as int? ?? 4,
      englishCompulsory: json['english_compulsory'] as bool? ?? true,
      hasTheory: json['has_theory'] as bool? ?? false,
      hasPractical: json['has_practical'] as bool? ?? false,
      hasComprehension: json['has_comprehension'] as bool? ?? false,
      hasRegister: json['has_register'] as bool? ?? false,
      hasLiterature: json['has_literature'] as bool? ?? false,
      showsPercentageAverage: json['shows_percentage_average'] as bool? ?? false,
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => ExamTypeSubjectRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
