import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/book_api.dart';
import '../../data/models/book_detail.dart';

part 'book_detail_controller.g.dart';

@riverpod
class BookDetailController extends _$BookDetailController {
  @override
  Future<BookDetail> build(String slug) {
    return ref.watch(bookApiProvider).getBook(slug);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}
