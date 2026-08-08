import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../providers/home_controller.dart';
import '../widgets/carousel_section.dart';
import '../widgets/continue_learning_section.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/leaderboard_section.dart';
import '../widgets/news_preview_section.dart';
import '../widgets/quick_actions_section.dart';
import '../widgets/recommended_courses_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/shepherd'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Ask Shepherd'),
      ),
      body: SafeArea(
        child: homeState.when(
          loading: () => const HomeShimmer(),
          error: (error, _) => AppErrorState(
            message: mapErrorToMessage(error),
            onRetry: () => ref.invalidate(homeControllerProvider),
          ),
          data: (home) => RefreshIndicator(
            onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                GreetingHeader(greeting: home.greeting, unreadNotifications: home.unreadNotifications),
                const SizedBox(height: AppSpacing.lg),
                CarouselSection(slides: home.carousel),
                const SizedBox(height: AppSpacing.lg),
                const QuickActionsSection(),
                const SizedBox(height: AppSpacing.lg),
                ContinueLearningSection(items: home.continueLearning),
                if (home.continueLearning.isNotEmpty) const SizedBox(height: AppSpacing.lg),
                RecommendedCoursesSection(courses: home.recommendedCourses),
                if (home.recommendedCourses.isNotEmpty) const SizedBox(height: AppSpacing.lg),
                LeaderboardSection(leaderboard: home.leaderboard),
                if (home.leaderboard.top.isNotEmpty) const SizedBox(height: AppSpacing.lg),
                NewsPreviewSection(news: home.news),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
