import 'package:hive_ce/hive.dart';

import 'hive_type_ids.dart';

part 'question_model.g.dart';

/// A single answer option — not a Hive object itself, just a plain
/// convenience wrapper built on demand from [QuestionModel.options].
class OptionModel {
  const OptionModel({required this.key, required this.text, this.imageUrl});

  /// 'a'..'e'.
  final String key;
  final String text;
  final String? imageUrl;
}

@HiveType(typeId: kHiveTypeQuestion)
class QuestionModel {
  QuestionModel({
    required this.id,
    required this.examTypeId,
    required this.subjectId,
    this.topicId,
    this.year,
    required this.questionType,
    required this.body,
    this.bodyImageUrl,
    this.optionA,
    this.optionAImageUrl,
    this.optionB,
    this.optionBImageUrl,
    this.optionC,
    this.optionCImageUrl,
    this.optionD,
    this.optionDImageUrl,
    this.optionE,
    this.optionEImageUrl,
    this.correctOption,
    this.correctAnswerText,
    this.explanation,
    this.explanationImageUrl,
    required this.specialType,
    this.passageGroupId,
    this.passageOrder,
    required this.updatedAt,
  });

  @HiveField(0)
  final int id;
  @HiveField(1)
  final int examTypeId;
  @HiveField(2)
  final int subjectId;
  @HiveField(3)
  final int? topicId;
  @HiveField(4)
  final int? year;

  /// `objective` | `theory` | `practical`.
  @HiveField(5)
  final String questionType;
  @HiveField(6)
  final String body;
  @HiveField(7)
  final String? bodyImageUrl;
  @HiveField(8)
  final String? optionA;
  @HiveField(9)
  final String? optionAImageUrl;
  @HiveField(10)
  final String? optionB;
  @HiveField(11)
  final String? optionBImageUrl;
  @HiveField(12)
  final String? optionC;
  @HiveField(13)
  final String? optionCImageUrl;
  @HiveField(14)
  final String? optionD;
  @HiveField(15)
  final String? optionDImageUrl;
  @HiveField(16)
  final String? optionE;
  @HiveField(17)
  final String? optionEImageUrl;

  /// 'a'..'e' — only ever synced for a paid user's own device; never
  /// exposed by the backend for a live/in-progress session's questions.
  @HiveField(18)
  final String? correctOption;
  @HiveField(19)
  final String? correctAnswerText;
  @HiveField(20)
  final String? explanation;
  @HiveField(21)
  final String? explanationImageUrl;

  /// `normal` | `comprehension` | `register` | `literature`.
  @HiveField(22)
  final String specialType;
  @HiveField(23)
  final int? passageGroupId;
  @HiveField(24)
  final int? passageOrder;

  /// Unix timestamp (seconds) — matches `Question::toSyncArray()`, used as
  /// the delta-sync cursor.
  @HiveField(25)
  final int updatedAt;

  List<OptionModel> get options {
    final all = [
      if (optionA != null) OptionModel(key: 'a', text: optionA!, imageUrl: optionAImageUrl),
      if (optionB != null) OptionModel(key: 'b', text: optionB!, imageUrl: optionBImageUrl),
      if (optionC != null) OptionModel(key: 'c', text: optionC!, imageUrl: optionCImageUrl),
      if (optionD != null) OptionModel(key: 'd', text: optionD!, imageUrl: optionDImageUrl),
      if (optionE != null) OptionModel(key: 'e', text: optionE!, imageUrl: optionEImageUrl),
    ];
    return all;
  }

  bool get isObjective => questionType == 'objective';

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as int,
      examTypeId: json['exam_type_id'] as int,
      subjectId: json['subject_id'] as int,
      topicId: json['topic_id'] as int?,
      year: json['year'] as int?,
      questionType: json['question_type'] as String? ?? 'objective',
      body: json['body'] as String? ?? '',
      bodyImageUrl: json['body_image_url'] as String?,
      optionA: json['option_a'] as String?,
      optionAImageUrl: json['option_a_image_url'] as String?,
      optionB: json['option_b'] as String?,
      optionBImageUrl: json['option_b_image_url'] as String?,
      optionC: json['option_c'] as String?,
      optionCImageUrl: json['option_c_image_url'] as String?,
      optionD: json['option_d'] as String?,
      optionDImageUrl: json['option_d_image_url'] as String?,
      optionE: json['option_e'] as String?,
      optionEImageUrl: json['option_e_image_url'] as String?,
      correctOption: json['correct_option'] as String?,
      correctAnswerText: json['correct_answer_text'] as String?,
      explanation: json['explanation'] as String?,
      explanationImageUrl: json['explanation_image_url'] as String?,
      specialType: json['special_type'] as String? ?? 'normal',
      passageGroupId: json['passage_group_id'] as int?,
      passageOrder: json['passage_order'] as int?,
      updatedAt: json['updated_at'] is int
          ? json['updated_at'] as int
          : (DateTime.tryParse(json['updated_at'] as String? ?? '')?.millisecondsSinceEpoch ?? 0) ~/ 1000,
    );
  }
}
