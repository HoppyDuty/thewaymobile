import 'package:flutter_test/flutter_test.dart';
import 'package:theway_mobile/features/shepherd/data/models/ai_quota_models.dart';
import 'package:theway_mobile/features/shepherd/data/models/chat_models.dart';
import 'package:theway_mobile/features/shepherd/data/models/weak_area_models.dart';

void main() {
  group('ChatMessage', () {
    test('isUser reflects the role field', () {
      final userMsg = ChatMessage.fromJson({'role': 'user', 'content': 'Hi'});
      final assistantMsg = ChatMessage.fromJson({'role': 'assistant', 'content': 'Hello!'});

      expect(userMsg.isUser, isTrue);
      expect(assistantMsg.isUser, isFalse);
    });
  });

  group('ConversationDetail', () {
    test('parses ordered message history', () {
      final detail = ConversationDetail.fromJson({
        'uuid': 'abc-123',
        'title': 'Maths help',
        'message_count': 2,
        'created_at': '2026-07-01T00:00:00Z',
        'messages': [
          {'role': 'user', 'content': 'Explain quadratics', 'created_at': '2026-07-01T00:00:00Z'},
          {'role': 'assistant', 'content': 'Sure! ...', 'created_at': '2026-07-01T00:00:05Z'},
        ],
      });

      expect(detail.messages, hasLength(2));
      expect(detail.messages.first.isUser, isTrue);
      expect(detail.title, 'Maths help');
    });
  });

  group('AiQuotas', () {
    test('exposes per-feature quota via named getters', () {
      final quotas = AiQuotas.fromJson({
        'explain': {'used': 5, 'limit': 100, 'remaining': 95, 'period': 'daily'},
        'chat': {'used': 50, 'limit': 50, 'remaining': 0, 'period': 'daily'},
        'study_plan': {'used': 1, 'limit': 3, 'remaining': 2, 'period': 'monthly'},
        'weak_area': {'used': 0, 'limit': 5, 'remaining': 5, 'period': 'daily'},
      });

      expect(quotas.chat?.remaining, 0);
      expect(quotas.studyPlan?.period, 'monthly');
      expect(quotas.explain?.limit, 100);
    });
  });

  group('WeakAreaAnalysis', () {
    test('flags subjects below 50% as weak', () {
      final analysis = WeakAreaAnalysis.fromJson({
        'narrative': 'You did well overall...',
        'from_cache': false,
        'weak_subjects': [
          {'subject_id': 1, 'subject_name': 'Mathematics', 'avg_score': 42.5, 'attempt_count': 3, 'is_weak': true},
          {'subject_id': 2, 'subject_name': 'English', 'avg_score': 78.0, 'attempt_count': 2, 'is_weak': false},
        ],
        'recommendations': [
          {'priority': 1, 'subject': 'Mathematics', 'action': 'Practice daily', 'resource': 'Past questions'},
        ],
      });

      expect(analysis.weakSubjects.where((s) => s.isWeak), hasLength(1));
      expect(analysis.recommendations.single.priority, 1);
    });
  });
}
