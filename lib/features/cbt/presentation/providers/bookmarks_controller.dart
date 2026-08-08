import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/hive_setup.dart';
import '../../data/cbt_api.dart';
import '../../data/models/question_model.dart';
import '../../data/services/offline_queue_service.dart';

part 'bookmarks_controller.g.dart';

/// Bookmarked questions ("My Questions") — the id list comes from the
/// server when online (and is cached to Hive `settings_box` for offline
/// use), then resolved against the locally-synced question bank so this
/// works fully offline once both have synced at least once.
@riverpod
class BookmarksController extends _$BookmarksController {
  static const _cacheKey = 'cbt_bookmark_ids';

  @override
  Future<List<QuestionModel>> build() async {
    List<int> ids;
    try {
      ids = await ref.read(cbtApiProvider).getBookmarks();
      await HiveSetup.settingsBox.put(_cacheKey, ids);
    } catch (_) {
      final cached = HiveSetup.settingsBox.get(_cacheKey);
      ids = cached is List ? cached.cast<int>() : const [];
    }

    final questionsBox = HiveSetup.questionsBox;
    return [for (final id in ids) if (questionsBox.get(id) != null) questionsBox.get(id)!];
  }

  Future<void> removeBookmark(int questionId) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.where((q) => q.id != questionId).toList());
    try {
      await ref.read(cbtApiProvider).toggleBookmark(questionId);
    } catch (_) {
      await ref.read(offlineQueueServiceProvider).enqueueBookmarkToggle(questionId, bookmarked: false);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
