import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/cbt/data/models/exam_type_model.dart';
import 'package:theway_mobile/features/cbt/data/models/question_model.dart';
import 'package:theway_mobile/features/cbt/data/services/local_scoring_service.dart';

ExamTypeModel _examType({
  bool hasAggregateMax = false,
  num? aggregateMaxScore,
  num maxScorePerSubject = 100,
}) {
  return ExamTypeModel(
    id: 1,
    name: 'UTME',
    slug: 'utme',
    price: 0,
    maxScorePerSubject: maxScorePerSubject,
    hasAggregateMax: hasAggregateMax,
    aggregateMaxScore: aggregateMaxScore,
    standardDurationMinutes: 120,
    englishQuestionCount: 60,
    otherSubjectQuestionCount: 40,
    minSubjects: 4,
    maxSubjects: 4,
    englishCompulsory: true,
    hasTheory: false,
    hasPractical: false,
    hasComprehension: false,
    hasRegister: false,
    hasLiterature: false,
    showsPercentageAverage: false,
  );
}

QuestionModel _objective({required int id, required int subjectId, required String correctOption}) {
  return QuestionModel(
    id: id,
    examTypeId: 1,
    subjectId: subjectId,
    questionType: 'objective',
    body: 'Q$id',
    correctOption: correctOption,
    specialType: 'normal',
    updatedAt: 0,
  );
}

QuestionModel _theory({required int id, required int subjectId}) {
  return QuestionModel(
    id: id,
    examTypeId: 1,
    subjectId: subjectId,
    questionType: 'theory',
    body: 'Q$id',
    specialType: 'normal',
    updatedAt: 0,
  );
}

void main() {
  final scorer = LocalScoringService();

  test('scores objective answers correctly and splits points evenly per subject', () {
    // Subject 1 has 4 questions worth 100 points total -> 25 pts each.
    final questions = {
      for (final q in [
        _objective(id: 1, subjectId: 1, correctOption: 'a'),
        _objective(id: 2, subjectId: 1, correctOption: 'b'),
        _objective(id: 3, subjectId: 1, correctOption: 'c'),
        _objective(id: 4, subjectId: 1, correctOption: 'd'),
      ])
        q.id: q,
    };

    final result = scorer.score(
      examType: _examType(),
      answers: {1: 'a', 2: 'a', 3: 'c', 4: null},
      subjectIds: [1],
      questionsById: questions,
    );

    expect(result.correct, 2); // Q1, Q3
    expect(result.wrong, 1); // Q2
    expect(result.skipped, 1); // Q4
    expect(result.attempted, 3);
    expect(result.score, 50.0); // 2 * 25
    expect(result.subjectBreakdown.single.scorePercent, 50.0);
  });

  test('theory answers count as attempted-but-ungraded, contributing zero score', () {
    final questions = {1: _theory(id: 1, subjectId: 1), 2: _theory(id: 2, subjectId: 1)};

    final result = scorer.score(
      examType: _examType(),
      answers: {1: 'my essay answer', 2: null},
      subjectIds: [1],
      questionsById: questions,
    );

    expect(result.correct, 1); // counted as attempted
    expect(result.skipped, 1);
    expect(result.score, 0); // no offline AI grading
    expect(result.pendingAiGradingCount, 1);
  });

  test('aggregate-max exam types (e.g. UTME) score against the fixed aggregate cap', () {
    final questions = {
      for (final q in [
        _objective(id: 1, subjectId: 1, correctOption: 'a'),
        _objective(id: 2, subjectId: 2, correctOption: 'a'),
      ])
        q.id: q,
    };

    final result = scorer.score(
      examType: _examType(hasAggregateMax: true, aggregateMaxScore: 400, maxScorePerSubject: 100),
      answers: {1: 'a', 2: 'a'},
      subjectIds: [1, 2],
      questionsById: questions,
    );

    // Each subject has 1 question worth its full 100-pt share -> 200 total / 400 cap = 50%.
    expect(result.maxScore, 400);
    expect(result.scorePercent, 50.0);
  });

  test('non-aggregate exam types (WAEC-style) average each subject\'s percentage', () {
    // Subject 1: 1/1 correct -> 100%. Subject 2: 0/1 correct -> 0%. Average = 50%.
    final questions = {
      1: _objective(id: 1, subjectId: 1, correctOption: 'a'),
      2: _objective(id: 2, subjectId: 2, correctOption: 'a'),
    };

    final result = scorer.score(
      examType: _examType(),
      answers: {1: 'a', 2: 'b'},
      subjectIds: [1, 2],
      questionsById: questions,
    );

    expect(result.scorePercent, 50.0);
  });
}
