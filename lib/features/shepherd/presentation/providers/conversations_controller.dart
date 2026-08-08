import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/chat_models.dart';
import '../../data/shepherd_api.dart';

part 'conversations_controller.g.dart';

class ConversationsState {
  const ConversationsState({required this.items, required this.hasMore, this.isLoadingMore = false});

  final List<ConversationSummary> items;
  final bool hasMore;
  final bool isLoadingMore;

  ConversationsState copyWith({List<ConversationSummary>? items, bool? hasMore, bool? isLoadingMore}) {
    return ConversationsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@riverpod
class ConversationsController extends _$ConversationsController {
  int _page = 1;

  @override
  Future<ConversationsState> build() async {
    _page = 1;
    final result = await ref.watch(shepherdApiProvider).listConversations(page: _page);
    return ConversationsState(items: result.items, hasMore: result.meta.hasMore);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(shepherdApiProvider).listConversations(page: _page + 1);
    _page += 1;
    state = AsyncData(ConversationsState(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(shepherdApiProvider).listConversations(page: 1);
      return ConversationsState(items: result.items, hasMore: result.meta.hasMore);
    });
  }

  Future<void> delete(String uuid) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.copyWith(items: current.items.where((c) => c.uuid != uuid).toList()));
    try {
      await ref.read(shepherdApiProvider).deleteConversation(uuid);
    } catch (_) {
      await refresh();
      rethrow;
    }
  }
}
