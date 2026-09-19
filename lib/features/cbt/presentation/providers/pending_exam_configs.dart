import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/exam_type_model.dart';
import '../../data/services/offline_question_builder.dart';

part 'pending_exam_configs.g.dart';

class ExamLaunchConfig {
  const ExamLaunchConfig({required this.examType, required this.sessionConfig, this.durationMinutes});

  final ExamTypeModel examType;
  final SessionConfig sessionConfig;

  /// Null = untimed. Resolved by the setup screen (fixed exam-type duration
  /// for Standard/Yearly, an optional user-picked duration for Practice,
  /// always null for Study/Topical).
  final int? durationMinutes;
}

/// A short-lived, in-memory handoff from the setup screen to
/// `ExamSessionController`: the setup screen generates a session key,
/// stashes the config here, then pushes `/cbt/exam/<key>` — the exam
/// screen's controller reads (and immediately clears) its entry on first
/// build. Avoids needing a complex-equality family parameter just to pass
/// a full config object through go_router.
@Riverpod(keepAlive: true)
class PendingExamConfigs extends _$PendingExamConfigs {
  @override
  Map<String, ExamLaunchConfig> build() => {};

  void put(String key, ExamLaunchConfig config) {
    state = {...state, key: config};
  }

  /// Read-only — Riverpod forbids a provider from mutating another
  /// provider's state while it's still building (see [remove]), so
  /// consumers reading this during their own `build()` must peek here and
  /// defer the actual removal rather than calling a mutating `take()`.
  ExamLaunchConfig? peek(String key) => state[key];

  void remove(String key) {
    if (state.containsKey(key)) {
      state = {...state}..remove(key);
    }
  }
}
