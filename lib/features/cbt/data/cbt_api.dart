import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';

part 'cbt_api.g.dart';

/// Thin wrapper around every real `/cbt/*` + `/sync/*` endpoint
/// (`CBTController.php`) — kept dumb (raw maps in/out) so the offline
/// services above it own all the actual sync/scoring/queueing logic.
class CbtApi {
  CbtApi(this._client);

  final ApiClient _client;

  Future<List<dynamic>> getExamTypes() async {
    final data = await _client.get('/cbt/exam-types');
    return data?['exam_types'] as List<dynamic>? ?? [];
  }

  Future<List<dynamic>> getSubjects() async {
    final data = await _client.get('/cbt/subjects');
    return data?['subjects'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getQuestionDelta({
    required int examTypeId,
    String? since,
    int page = 1,
  }) async {
    final data = await _client.get(
      '/cbt/questions/delta',
      query: {'exam_type_id': examTypeId, if (since != null) 'since': since, 'page': page},
    );
    return data ?? {};
  }

  Future<Map<String, dynamic>> startSession(Map<String, dynamic> config) async {
    final data = await _client.post('/cbt/sessions', data: config);
    return data ?? {};
  }

  Future<void> saveProgress({
    required String uuid,
    required Map<String, String?> answers,
    required int timeSpentSeconds,
    List<int> bookmarkedIds = const [],
    bool paused = false,
  }) {
    return _client.patch(
      '/cbt/sessions/$uuid/progress',
      data: {
        'answers': answers,
        'time_spent_seconds': timeSpentSeconds,
        'bookmarked_ids': bookmarkedIds,
        'paused': paused,
      },
    );
  }

  Future<Map<String, dynamic>> submitSession({
    required String uuid,
    required Map<String, String?> answers,
    required int timeSpentSeconds,
    List<int> bookmarkedIds = const [],
  }) async {
    final data = await _client.post(
      '/cbt/sessions/$uuid/submit',
      data: {
        'answers': answers,
        'time_spent_seconds': timeSpentSeconds,
        'bookmarked_ids': bookmarkedIds,
      },
    );
    return data ?? {};
  }

  Future<Map<String, dynamic>> getResult(String uuid) async {
    final data = await _client.get('/cbt/sessions/$uuid/result');
    return data ?? {};
  }

  Future<List<dynamic>> getCorrections(String uuid) async {
    final data = await _client.get('/cbt/sessions/$uuid/corrections');
    return data?['corrections'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> getAiGradingResult(String uuid) async {
    final data = await _client.get('/cbt/sessions/$uuid/ai-result');
    return data ?? {};
  }

  Future<Map<String, dynamic>> toggleBookmark(int questionId) async {
    final data = await _client.post('/cbt/bookmarks/$questionId');
    return data ?? {};
  }

  Future<List<int>> getBookmarks() async {
    final data = await _client.get('/cbt/bookmarks');
    return (data?['question_ids'] as List<dynamic>? ?? []).cast<int>();
  }

  /// Flushes queued [PendingOperation]s (offline exam sessions, bookmark
  /// toggles) up to the backend. `operations` are already-built
  /// `{type, payload}` maps — see `OfflineQueueService`.
  Future<List<dynamic>> syncFlush(List<Map<String, dynamic>> operations) async {
    final data = await _client.post('/sync/flush', data: {'operations': operations});
    return data?['results'] as List<dynamic>? ?? [];
  }

  Future<bool> reviewCheck() async {
    final data = await _client.get('/sync/review/check');
    return data?['should_prompt'] as bool? ?? false;
  }
}

@Riverpod(keepAlive: true)
CbtApi cbtApi(CbtApiRef ref) {
  return CbtApi(ref.watch(apiClientProvider));
}
