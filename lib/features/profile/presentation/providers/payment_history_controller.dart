import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/profile_models.dart';
import '../../data/profile_api.dart';

part 'payment_history_controller.g.dart';

class PaymentHistoryState {
  const PaymentHistoryState({required this.items, required this.hasMore, this.isLoadingMore = false});

  final List<PaymentHistoryItem> items;
  final bool hasMore;
  final bool isLoadingMore;

  PaymentHistoryState copyWith({List<PaymentHistoryItem>? items, bool? hasMore, bool? isLoadingMore}) {
    return PaymentHistoryState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class PaymentHistoryController extends _$PaymentHistoryController {
  int _page = 1;

  @override
  Future<PaymentHistoryState> build() async {
    _page = 1;
    final result = await ref.watch(profileApiProvider).getPaymentHistory(page: _page);
    return PaymentHistoryState(items: result.items, hasMore: result.meta.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(profileApiProvider).getPaymentHistory(page: _page + 1);
    _page += 1;
    state = AsyncData(PaymentHistoryState(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(profileApiProvider).getPaymentHistory(page: 1);
      return PaymentHistoryState(items: result.items, hasMore: result.meta.hasMore);
    });
  }
}
