import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/cbt/data/cbt_api.dart';

part 'review_prompt_service.g.dart';

/// Prompts for an app store review at a positive moment (right after a CBT
/// exam submission) — but only when the server's own 90-day throttle
/// (`GET /sync/review/check`) says it's time, so we don't burn through the
/// OS's own internal review-prompt budget (both Android and iOS silently
/// cap how often the real dialog appears, regardless of how often we ask).
class ReviewPromptService {
  ReviewPromptService(this._cbtApi);

  final CbtApi _cbtApi;

  Future<void> maybePromptAfterExam() async {
    try {
      final shouldPrompt = await _cbtApi.reviewCheck();
      if (!shouldPrompt) return;

      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
      }
    } catch (_) {
      // Best-effort — never let this affect the exam-result flow.
    }
  }
}

@Riverpod(keepAlive: true)
ReviewPromptService reviewPromptService(ReviewPromptServiceRef ref) {
  return ReviewPromptService(ref.watch(cbtApiProvider));
}
