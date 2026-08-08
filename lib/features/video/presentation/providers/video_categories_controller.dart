import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/video_category.dart';
import '../../data/video_api.dart';

part 'video_categories_controller.g.dart';

@riverpod
Future<List<VideoCategory>> videoCategories(VideoCategoriesRef ref) {
  return ref.watch(videoApiProvider).getCategories();
}
