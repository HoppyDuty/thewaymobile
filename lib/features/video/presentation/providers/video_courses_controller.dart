import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/video_course_summary.dart';
import '../../data/video_api.dart';

part 'video_courses_controller.g.dart';

class VideoCoursesState {
  const VideoCoursesState({required this.items, required this.hasMore, this.isLoadingMore = false});

  final List<VideoCourseSummary> items;
  final bool hasMore;
  final bool isLoadingMore;

  VideoCoursesState copyWith({List<VideoCourseSummary>? items, bool? hasMore, bool? isLoadingMore}) {
    return VideoCoursesState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Family keyed by category id (null = all courses) — switching the
/// category filter chip just watches a different provider instance, each
/// with its own independent pagination state.
@riverpod
class VideoCoursesController extends _$VideoCoursesController {
  int _page = 1;

  @override
  Future<VideoCoursesState> build(int? categoryId) async {
    _page = 1;
    final result = await ref.watch(videoApiProvider).listCourses(page: _page, categoryId: categoryId);
    return VideoCoursesState(items: result.items, hasMore: result.meta.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(videoApiProvider).listCourses(page: _page + 1, categoryId: categoryId);
    _page += 1;
    state = AsyncData(VideoCoursesState(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(videoApiProvider).listCourses(page: 1, categoryId: categoryId);
      return VideoCoursesState(items: result.items, hasMore: result.meta.hasMore);
    });
  }
}
