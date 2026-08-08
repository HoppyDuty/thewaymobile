import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/notification_model.dart';
import '../../data/notifications_api.dart';

part 'notifications_controller.g.dart';

class NotificationsState {
  const NotificationsState({required this.items, required this.hasMore, required this.unreadCount});
  final List<NotificationModel> items;
  final bool hasMore;
  final int unreadCount;

  NotificationsState copyWith({List<NotificationModel>? items, bool? hasMore, int? unreadCount}) {
    return NotificationsState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

@riverpod
class NotificationsController extends _$NotificationsController {
  int _page = 1;

  @override
  Future<NotificationsState> build() async {
    _page = 1;
    final result = await ref.watch(notificationsApiProvider).list(page: 1);
    return NotificationsState(items: result.items, hasMore: result.meta.hasMore, unreadCount: result.unreadCount);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;
    final result = await ref.read(notificationsApiProvider).list(page: _page + 1);
    _page += 1;
    state = AsyncData(current.copyWith(items: [...current.items, ...result.items], hasMore: result.meta.hasMore));
  }

  Future<void> refresh() async {
    _page = 1;
    state = await AsyncValue.guard(() async {
      final result = await ref.read(notificationsApiProvider).list(page: 1);
      return NotificationsState(items: result.items, hasMore: result.meta.hasMore, unreadCount: result.unreadCount);
    });
  }

  Future<void> markRead(int id) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final wasUnread = current.items.firstWhere((n) => n.id == id).isRead == false;
    state = AsyncData(current.copyWith(
      items: [for (final n in current.items) if (n.id == id) n.copyWith(isRead: true) else n],
      unreadCount: wasUnread ? current.unreadCount - 1 : current.unreadCount,
    ));

    await ref.read(notificationsApiProvider).markRead(id);
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;

    state = AsyncData(current.copyWith(
      items: [for (final n in current.items) n.copyWith(isRead: true)],
      unreadCount: 0,
    ));

    await ref.read(notificationsApiProvider).markAllRead();
  }
}
