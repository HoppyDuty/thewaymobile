import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/app_version/app_gate_controller.dart';
import '../../features/app_version/app_gate_state.dart';
import '../../features/app_version/force_update_screen.dart';
import '../../features/app_version/maintenance_screen.dart';
import '../../features/auth/presentation/providers/auth_session_controller.dart';
import '../../features/auth/presentation/providers/auth_session_state.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/books/presentation/screens/book_detail_screen.dart';
import '../../features/books/presentation/screens/books_list_screen.dart';
import '../../features/books/presentation/screens/my_books_screen.dart';
import '../../features/books/presentation/screens/pdf_reader_screen.dart';
import '../../features/cbt/data/models/exam_type_model.dart';
import '../../features/cbt/presentation/providers/cbt_flow_args.dart';
import '../../features/cbt/presentation/screens/bookmarks_screen.dart';
import '../../features/cbt/presentation/screens/exam_screen.dart';
import '../../features/cbt/presentation/screens/exam_types_screen.dart';
import '../../features/cbt/presentation/screens/mode_selection_screen.dart';
import '../../features/cbt/presentation/screens/result_screen.dart';
import '../../features/cbt/presentation/screens/review_screen.dart';
import '../../features/cbt/presentation/screens/session_setup_screen.dart';
import '../../features/cbt/presentation/screens/subject_selection_screen.dart';
import '../../features/cbt/presentation/screens/topic_selection_screen.dart';
import '../../features/dictionary/presentation/screens/dictionary_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/leaderboard_screen.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/news/presentation/screens/news_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/onboarding/onboarding_service.dart';
import '../../features/profile/presentation/screens/delete_account_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/payment_history_screen.dart';
import '../../features/profile/presentation/screens/preferences_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/purchases_screen.dart';
import '../../features/profile/presentation/screens/stats_screen.dart';
import '../../features/shepherd/presentation/screens/chat_screen.dart';
import '../../features/shepherd/presentation/screens/shepherd_home_screen.dart';
import '../../features/shepherd/presentation/screens/study_plan_screen.dart';
import '../../features/shepherd/presentation/screens/weak_areas_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/video/presentation/screens/local_video_player_screen.dart';
import '../../features/video/presentation/screens/video_course_detail_screen.dart';
import '../../features/video/presentation/screens/video_courses_screen.dart';
import '../../features/video/presentation/screens/video_downloads_screen.dart';
import '../../features/video/presentation/screens/video_player_screen.dart';
import 'app_page_transitions.dart';
import 'go_router_refresh_notifier.dart';

part 'app_router.g.dart';

abstract final class AppRoute {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const otpVerify = '/otp-verify';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const forceUpdate = '/force-update';
  static const maintenance = '/maintenance';
  static const home = '/home';
  static const news = '/news';
  static const notifications = '/notifications';
  static const dictionary = '/dictionary';
}

const _preAuthRoutes = {
  AppRoute.login,
  AppRoute.register,
  AppRoute.otpVerify,
  AppRoute.forgotPassword,
  AppRoute.resetPassword,
  AppRoute.onboarding,
};

@Riverpod(keepAlive: true)
GoRouter appRouter(AppRouterRef ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref, [
    appGateControllerProvider,
    authSessionControllerProvider,
  ]);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoute.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final gate = ref.read(appGateControllerProvider);

      if (gate is AppGateChecking) {
        return location == AppRoute.splash ? null : AppRoute.splash;
      }

      if (gate is AppGateBlocked) {
        final target = gate.check.maintenance ? AppRoute.maintenance : AppRoute.forceUpdate;
        return location == target ? null : target;
      }

      final authState = ref.read(authSessionControllerProvider);

      if (authState is AuthSessionUnknown) {
        return location == AppRoute.splash ? null : AppRoute.splash;
      }

      if (authState is AuthSessionUnauthenticated) {
        if (_preAuthRoutes.contains(location)) return null;
        final hasSeenOnboarding = ref.read(onboardingServiceProvider).hasSeenOnboarding;
        return hasSeenOnboarding ? AppRoute.login : AppRoute.onboarding;
      }

      // Authenticated.
      if (location == AppRoute.splash || _preAuthRoutes.contains(location)) {
        return AppRoute.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoute.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: AppRoute.onboarding,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: AppRoute.login,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const LoginScreen()),
      ),
      GoRoute(
        path: AppRoute.register,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoute.otpVerify,
        pageBuilder: (context, state) =>
            buildModalPage(context, state, OtpVerifyScreen(args: state.extra! as OtpVerifyArgs)),
      ),
      GoRoute(
        path: AppRoute.forgotPassword,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: AppRoute.resetPassword,
        pageBuilder: (context, state) =>
            buildModalPage(context, state, ResetPasswordScreen(resetToken: state.extra! as String)),
      ),
      GoRoute(
        path: AppRoute.forceUpdate,
        builder: (context, state) {
          final gate = ref.read(appGateControllerProvider);
          final check = gate is AppGateBlocked ? gate.check : null;
          return ForceUpdateScreen(updateUrl: check?.updateUrl, message: check?.message);
        },
      ),
      GoRoute(
        path: AppRoute.maintenance,
        builder: (context, state) {
          final gate = ref.read(appGateControllerProvider);
          final check = gate is AppGateBlocked ? gate.check : null;
          return MaintenanceScreen(
            title: check?.maintenanceTitle,
            message: check?.message ?? "We'll be right back.",
            endsAt: check?.maintenanceEndsAt,
          );
        },
      ),

      // ── Full-screen routes reached from within the tabs (no bottom nav) ──
      // All use `buildPageWithTransition` (fade + forward-slide) or
      // `buildModalPage` (slide-up) so navigation always animates instead of
      // hard-cutting between screens (`uiuxrules.md` §4).
      GoRoute(
        path: AppRoute.news,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const NewsListScreen()),
      ),
      GoRoute(
        path: '/news/:slug',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, NewsDetailScreen(slug: state.pathParameters['slug']!)),
      ),
      GoRoute(
        path: AppRoute.notifications,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoute.dictionary,
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const DictionaryScreen()),
      ),
      GoRoute(
        path: '/videos/downloads',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const VideoDownloadsScreen()),
      ),
      GoRoute(
        path: '/videos/local-player',
        pageBuilder: (context, state) {
          final args = state.extra! as LocalVideoPlayerArgs;
          return buildModalPage(context, state, LocalVideoPlayerScreen(filePath: args.filePath, title: args.title));
        },
      ),
      GoRoute(
        path: '/videos/:slug',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, VideoCourseDetailScreen(slug: state.pathParameters['slug']!)),
      ),
      GoRoute(
        path: '/videos/:slug/lessons/:lessonId',
        pageBuilder: (context, state) => buildModalPage(
          context,
          state,
          VideoPlayerScreen(
            slug: state.pathParameters['slug']!,
            lessonId: int.parse(state.pathParameters['lessonId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/books/saved',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const MyBooksScreen()),
      ),
      GoRoute(
        path: '/books/:slug',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, BookDetailScreen(slug: state.pathParameters['slug']!)),
      ),
      GoRoute(
        path: '/books/:slug/read',
        pageBuilder: (context, state) =>
            buildModalPage(context, state, PdfReaderScreen(args: state.extra! as PdfReaderArgs)),
      ),
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) => buildModalPage(context, state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/profile/stats',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const StatsScreen()),
      ),
      GoRoute(
        path: '/profile/purchases',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const PurchasesScreen()),
      ),
      GoRoute(
        path: '/profile/payments',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const PaymentHistoryScreen()),
      ),
      GoRoute(
        path: '/profile/preferences',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const PreferencesScreen()),
      ),
      GoRoute(
        path: '/profile/delete-account',
        pageBuilder: (context, state) => buildModalPage(context, state, const DeleteAccountScreen()),
      ),
      GoRoute(
        path: '/shepherd',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const ShepherdHomeScreen()),
      ),
      GoRoute(
        path: '/shepherd/chat',
        pageBuilder: (context, state) => buildModalPage(context, state, const ChatScreen()),
      ),
      GoRoute(
        path: '/shepherd/chat/:uuid',
        pageBuilder: (context, state) =>
            buildModalPage(context, state, ChatScreen(conversationUuid: state.pathParameters['uuid'])),
      ),
      GoRoute(
        path: '/shepherd/weak-areas',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const WeakAreasScreen()),
      ),
      GoRoute(
        path: '/shepherd/study-plan',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const StudyPlanScreen()),
      ),
      GoRoute(
        path: '/cbt/mode',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, ModeSelectionScreen(examType: state.extra! as ExamTypeModel)),
      ),
      GoRoute(
        path: '/cbt/subjects',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, SubjectSelectionScreen(args: state.extra! as CbtFlowArgs)),
      ),
      GoRoute(
        path: '/cbt/topics',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, TopicSelectionScreen(args: state.extra! as CbtFlowArgs)),
      ),
      GoRoute(
        path: '/cbt/setup',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, SessionSetupScreen(args: state.extra! as CbtFlowArgs)),
      ),
      GoRoute(
        path: '/cbt/exam/:sessionKey',
        pageBuilder: (context, state) =>
            buildModalPage(context, state, ExamScreen(sessionKey: state.pathParameters['sessionKey']!)),
      ),
      GoRoute(
        path: '/cbt/exam/:sessionKey/result',
        pageBuilder: (context, state) =>
            buildModalPage(context, state, ResultScreen(sessionKey: state.pathParameters['sessionKey']!)),
      ),
      GoRoute(
        path: '/cbt/exam/:sessionKey/review',
        pageBuilder: (context, state) =>
            buildPageWithTransition(context, state, ReviewScreen(sessionKey: state.pathParameters['sessionKey']!)),
      ),
      GoRoute(
        path: '/cbt/bookmarks',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const BookmarksScreen()),
      ),
      GoRoute(
        path: '/profile/leaderboard',
        pageBuilder: (context, state) => buildPageWithTransition(context, state, const LeaderboardScreen()),
      ),

      // ── Bottom-nav tabs ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoute.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cbt', builder: (context, state) => const ExamTypesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/videos', builder: (context, state) => const VideoCoursesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/books', builder: (context, state) => const BooksListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
}
