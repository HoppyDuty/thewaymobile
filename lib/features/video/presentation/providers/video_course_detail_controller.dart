import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/video_course_detail.dart';
import '../../data/video_api.dart';

part 'video_course_detail_controller.g.dart';

@riverpod
class VideoCourseDetailController extends _$VideoCourseDetailController {
  @override
  Future<VideoCourseDetail> build(String slug) {
    return ref.watch(videoApiProvider).getCourse(slug);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
