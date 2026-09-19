import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/cbt/data/models/exam_type_model.dart';
import 'package:theway_mobile/features/cbt/data/models/question_model.dart';
import 'package:theway_mobile/features/cbt/presentation/providers/exam_session_controller.dart';

ExamTypeModel _examType() {
  return ExamTypeModel(
    id: 1,
    name: 'UTME',
    slug: 'utme',
    price: 0,
    maxScorePerSubject: 100,
    hasAggregateMax: false,
    aggregateMaxScore: null,
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

QuestionModel _question({required int id, required String correctOption}) {
  return QuestionModel(
    id: id,
    examTypeId: 1,
    subjectId: 1,
    questionType: 'objective',
    body: 'Q$id',
    optionA: 'Option A text',
    optionB: 'Option B text',
    optionC: 'Option C text',
    optionD: 'Option D text',
    correctOption: correctOption,
    specialType: 'normal',
    updatedAt: 0,
  );
}

ExamSessionState _stateWith({required QuestionModel question, required Map<int, List<String>> optionOrders}) {
  return ExamSessionState(
    sessionUuid: 'uuid-1',
    examType: _examType(),
    mode: 'practice',
    isOnlineSession: false,
    subjectIds: [1],
    questionsBySubject: {1: [question]},
    orderedQuestions: [question],
    answers: const {},
    bookmarkedIds: const {},
    remainingSeconds: null,
    currentIndex: 0,
    startedAt: 0,
    optionOrders: optionOrders,
  );
}

void main() {
  group('ExamSessionState.orderedOptionsFor', () {
    test('reorders options per the pinned optionOrders without losing any', () {
      final question = _question(id: 1, correctOption: 'b');
      final state = _stateWith(
        question: question,
        optionOrders: {
          1: ['c', 'a', 'd', 'b'],
        },
      );

      final ordered = state.orderedOptionsFor(question);

      expect(ordered.map((o) => o.key).toList(), ['c', 'a', 'd', 'b']);
      expect(ordered.map((o) => o.key).toSet(), question.options.map((o) => o.key).toSet());
    });

    test('correctness still keys off the stable option key, not display position', () {
      // Correct answer is 'b' ("Option B text"), but after shuffling it's
      // rendered in position 0 (first), not its original position 1.
      final question = _question(id: 1, correctOption: 'b');
      final state = _stateWith(
        question: question,
        optionOrders: {
          1: ['b', 'a', 'c', 'd'],
        },
      );

      final ordered = state.orderedOptionsFor(question);
      final correctOptionNowAtIndex0 = ordered[0];

      // The option now displayed FIRST is still the one whose key matches
      // question.correctOption — shuffling the display order must never
      // detach "isCorrect" from the option's actual content.
      expect(correctOptionNowAtIndex0.key, question.correctOption);
      expect(correctOptionNowAtIndex0.text, 'Option B text');
    });

    test('falls back to natural order when a question has no pinned entry', () {
      final question = _question(id: 1, correctOption: 'a');
      final state = _stateWith(question: question, optionOrders: const {});

      final ordered = state.orderedOptionsFor(question);

      expect(ordered.map((o) => o.key).toList(), ['a', 'b', 'c', 'd']);
    });
  });
}
