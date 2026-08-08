import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/page_meta.dart';
import 'models/ai_quota_models.dart';
import 'models/chat_models.dart';
import 'models/study_plan_models.dart';
import 'models/weak_area_models.dart';

part 'shepherd_api.g.dart';

class ShepherdExplanation {
  const ShepherdExplanation({
    required this.explanation,
    required this.commonMistakes,
    required this.keyConcepts,
    required this.fromCache,
  });

  /// HTML string.
  final String explanation;
  final List<String> commonMistakes;
  final List<String> keyConcepts;
  final bool fromCache;

  factory ShepherdExplanation.fromJson(Map<String, dynamic> json) {
    return ShepherdExplanation(
      explanation: json['explanation'] as String? ?? '',
      commonMistakes: List<String>.from(json['common_mistakes'] as List? ?? []),
      keyConcepts: List<String>.from(json['key_concepts'] as List? ?? []),
      fromCache: json['from_cache'] as bool? ?? false,
    );
  }
}

class ConversationsPage {
  const ConversationsPage({required this.items, required this.meta});
  final List<ConversationSummary> items;
  final PageMeta meta;
}

/// Client for Shepherd (the AI tutor) — question explanations (used by
/// "Ask AI" buttons throughout CBT/Dictionary), the full multi-turn chat,
/// weak-area analysis, study plan generation, and quota tracking.
class ShepherdApi {
  ShepherdApi(this._client);

  final ApiClient _client;

  Future<ShepherdExplanation> explainQuestion(int questionId) async {
    final data = await _client.post('/shepherd/explain', data: {'question_id': questionId});
    return ShepherdExplanation.fromJson(data!);
  }

  /// A single free-form message with no conversation history attached —
  /// used for one-shot "ask AI about X" actions (e.g. dictionary lookups)
  /// rather than the full multi-turn chat.
  Future<String> quickAsk(String message) async {
    final data = await _client.post('/shepherd/chat', data: {'message': message});
    return data!['message'] as String;
  }

  Future<ChatResult> chat({required String message, String? conversationUuid, int? examTypeId}) async {
    final data = await _client.post(
      '/shepherd/chat',
      data: {
        'message': message,
        if (conversationUuid != null) 'conversation_uuid': conversationUuid,
        if (examTypeId != null) 'exam_type_id': examTypeId,
      },
    );
    return ChatResult.fromJson(data!);
  }

  Future<ConversationsPage> listConversations({int page = 1}) async {
    final envelope = await _client.getPage('/shepherd/conversations', query: {'page': page});
    return ConversationsPage(
      items: envelope.list.map((c) => ConversationSummary.fromJson(c as Map<String, dynamic>)).toList(),
      meta: PageMeta.fromJson(envelope.meta),
    );
  }

  Future<ConversationDetail> getConversation(String uuid) async {
    final data = await _client.get('/shepherd/conversations/$uuid');
    return ConversationDetail.fromJson(data!);
  }

  Future<void> deleteConversation(String uuid) {
    return _client.delete('/shepherd/conversations/$uuid');
  }

  Future<WeakAreaAnalysis> analyzeWeakAreas({int? examTypeId}) async {
    final data = await _client.post('/shepherd/weak-areas', data: {if (examTypeId != null) 'exam_type_id': examTypeId});
    return WeakAreaAnalysis.fromJson(data!);
  }

  Future<StudyPlan> generateStudyPlan({
    required DateTime examDate,
    int? examTypeId,
    List<String> focusSubjects = const [],
    String? extraContext,
  }) async {
    final data = await _client.post(
      '/shepherd/study-plan',
      data: {
        'exam_date': examDate.toIso8601String().split('T').first,
        if (examTypeId != null) 'exam_type_id': examTypeId,
        if (focusSubjects.isNotEmpty) 'focus_subjects': focusSubjects,
        if (extraContext != null && extraContext.isNotEmpty) 'extra_context': extraContext,
      },
    );
    return StudyPlan.fromJson(data!);
  }

  Future<StudyPlan?> getActiveStudyPlan({int? examTypeId}) async {
    final data = await _client.get('/shepherd/study-plan', query: {if (examTypeId != null) 'exam_type_id': examTypeId});
    final plan = data?['plan'];
    return plan != null ? StudyPlan.fromJson(plan as Map<String, dynamic>) : null;
  }

  Future<AiQuotas> getQuotas() async {
    final data = await _client.get('/shepherd/quotas');
    return AiQuotas.fromJson(data?['quotas'] as Map<String, dynamic>? ?? {});
  }
}

@Riverpod(keepAlive: true)
ShepherdApi shepherdApi(ShepherdApiRef ref) => ShepherdApi(ref.watch(apiClientProvider));
