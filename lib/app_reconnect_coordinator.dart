import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'core/connectivity/connectivity_provider.dart';
import 'features/books/presentation/providers/book_list_controller.dart';
import 'features/cbt/data/services/sync_manager.dart';
import 'features/home/presentation/providers/home_controller.dart';
import 'features/home/presentation/providers/leaderboard_controller.dart';
import 'features/news/presentation/providers/news_list_controller.dart';
import 'features/notifications/presentation/providers/notifications_controller.dart';
import 'features/profile/presentation/providers/profile_controller.dart';
import 'features/video/presentation/providers/video_courses_controller.dart';

part 'app_reconnect_coordinator.g.dart';

/// App-wide offline→online reconnect trigger (`UI_UX_RULES.md` §11).
///
/// Previously only CBT's `SyncManager` listened for reconnects, and only
/// once something had built it — in practice, only after the user visited
/// the CBT tab, so a session that never opened CBT never synced at all.
/// Watched once from [TheWayApp]'s root (`app.dart`), so this is alive for
/// the whole session regardless of which tab the user visits, and fans a
/// single reconnect event out to every feature with its own offline-aware
/// provider instead of each screen re-implementing this independently
/// (`uiuxrules.md` §29 — centralized connectivity infrastructure, not
/// per-screen logic).
@Riverpod(keepAlive: true)
class AppReconnectCoordinator extends _$AppReconnectCoordinator {
  @override
  void build() {
    // Assume online at cold start — there's nothing to "reconnect" from
    // yet, and every provider below already fetches fresh data on its own
    // first build.
    var wasOnline = true;
    ref.listen(connectivityProvider, (previous, next) {
      final isOnline = next.valueOrNull;
      if (isOnline == null) return;
      if (isOnline && !wasOnline) {
        ref.read(syncManagerProvider.notifier).syncNow();
        ref.invalidate(homeControllerProvider);
        ref.invalidate(leaderboardControllerProvider);
        ref.invalidate(videoCoursesControllerProvider);
        ref.invalidate(bookListControllerProvider);
        ref.invalidate(newsListControllerProvider);
        ref.invalidate(notificationsControllerProvider);
        ref.invalidate(profileControllerProvider);
      }
      wasOnline = isOnline;
    });
  }
}
