import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../features/cbt/data/models/delta_checkpoint_model.dart';
import '../../features/cbt/data/models/exam_type_model.dart';
import '../../features/cbt/data/models/offline_session_model.dart';
import '../../features/cbt/data/models/pending_operation_model.dart';
import '../../features/cbt/data/models/question_model.dart';
import '../../features/cbt/data/models/question_passage_group_model.dart';
import '../../features/cbt/data/models/subject_model.dart';
import '../../features/books/data/models/saved_book_model.dart';
import '../../features/video/data/models/downloaded_video_model.dart';
import '../../hive_registrar.g.dart';

/// Boots Hive and registers every feature's [TypeAdapter]s in one place.
///
/// Type IDs are allocated per feature so they never collide as the app
/// grows — see the table below. `phase4.md`'s CBT/offline-sync spec
/// already reserves 11–17 and 60, so those ranges are off-limits for
/// anything else:
///
/// | Range | Feature |
/// |---|---|
/// | 0–9 | Auth (device session cache, cached profile) |
/// | 11–17 | CBT (`ExamType`, `Subject`, `Topic`, `Question`, `PassageGroup`, `OfflineSession`, `DeltaCheckpoint` — per `phase4.md`) |
/// | 20–29 | Home / News / Notifications |
/// | 30–39 | Video |
/// | 40–49 | Books |
/// | 50–59 | Profile |
/// | 60 | `PendingOperation` (sync queue — per `phase4.md`) |
/// | 61–69 | reserved for further sync/offline models |
///
/// Simple single-object caches (e.g. "the current user profile") are
/// stored as plain JSON maps in an untyped [Box] rather than needing a
/// generated [TypeAdapter] — that machinery is reserved for models where
/// type safety/query performance actually matters (CBT questions, etc.).
abstract final class HiveSetup {
  static const authBoxName = 'auth_box';
  static const settingsBoxName = 'settings_box';
  static const offlineCacheBoxName = 'offline_cache_box';

  // CBT — long-lived local exam-bank/session storage (no TTL eviction; this
  // is what satisfies the "offline for 2+ months" requirement, by design).
  static const examTypesBoxName = 'cbt_exam_types_box';
  static const subjectsBoxName = 'cbt_subjects_box';
  static const questionsBoxName = 'cbt_questions_box';
  static const passageGroupsBoxName = 'cbt_passage_groups_box';
  static const offlineSessionsBoxName = 'cbt_offline_sessions_box';
  static const deltaCheckpointsBoxName = 'cbt_delta_checkpoints_box';
  static const pendingOperationsBoxName = 'cbt_pending_operations_box';

  // Video — locally-saved lesson files for offline playback (typeId 30).
  static const videoDownloadsBoxName = 'video_downloads_box';

  // Books — locally-saved PDFs for offline reading (typeId 40).
  static const savedBooksBoxName = 'saved_books_box';

  static bool _initialized = false;

  /// [testDirectoryPath] lets tests bypass `Hive.initFlutter()` (which
  /// resolves the storage directory via a `path_provider` platform channel
  /// unavailable under plain `flutter test`) in favor of `Hive.init()` with
  /// an explicit, plain-Dart temp directory — production callers never
  /// pass this, so real app boot is unaffected.
  static Future<void> init({String? testDirectoryPath}) async {
    if (_initialized) return;

    if (testDirectoryPath != null) {
      Hive.init(testDirectoryPath);
    } else {
      await Hive.initFlutter();
    }

    Hive.registerAdapters();

    await Hive.openBox(authBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(offlineCacheBoxName);

    await Hive.openBox<ExamTypeModel>(examTypesBoxName);
    await Hive.openBox<SubjectModel>(subjectsBoxName);
    await Hive.openBox<QuestionModel>(questionsBoxName);
    await Hive.openBox<QuestionPassageGroupModel>(passageGroupsBoxName);
    await Hive.openBox<OfflineSessionModel>(offlineSessionsBoxName);
    await Hive.openBox<DeltaCheckpointModel>(deltaCheckpointsBoxName);
    await Hive.openBox<PendingOperation>(pendingOperationsBoxName);
    await Hive.openBox<DownloadedVideoModel>(videoDownloadsBoxName);
    await Hive.openBox<SavedBookModel>(savedBooksBoxName);

    _initialized = true;
  }

  static Box get authBox => Hive.box(authBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box get offlineCacheBox => Hive.box(offlineCacheBoxName);

  static Box<ExamTypeModel> get examTypesBox => Hive.box(examTypesBoxName);
  static Box<SubjectModel> get subjectsBox => Hive.box(subjectsBoxName);
  static Box<QuestionModel> get questionsBox => Hive.box(questionsBoxName);
  static Box<QuestionPassageGroupModel> get passageGroupsBox => Hive.box(passageGroupsBoxName);
  static Box<OfflineSessionModel> get offlineSessionsBox => Hive.box(offlineSessionsBoxName);
  static Box<DeltaCheckpointModel> get deltaCheckpointsBox => Hive.box(deltaCheckpointsBoxName);
  static Box<PendingOperation> get pendingOperationsBox => Hive.box(pendingOperationsBoxName);
  static Box<DownloadedVideoModel> get videoDownloadsBox => Hive.box(videoDownloadsBoxName);
  static Box<SavedBookModel> get savedBooksBox => Hive.box(savedBooksBoxName);
}
