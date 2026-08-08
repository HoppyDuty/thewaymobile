import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/book_api.dart';
import '../../data/models/book_category.dart';

part 'book_categories_controller.g.dart';

@riverpod
Future<List<BookCategory>> bookCategories(BookCategoriesRef ref) {
  return ref.watch(bookApiProvider).getCategories();
}
