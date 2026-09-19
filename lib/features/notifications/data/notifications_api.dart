import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/page_meta.dart';
import '../../../core/storage/offline_cache.dart';
import 'models/notification_model.dart';

part 'notifications_api.g.dart';

class NotificationsApi {
  NotificationsApi(this._client, this._cache);

  final ApiClient _client;
  final OfflineCache _cache;

  /// `data` is a bare JSON array (paginated); `meta` additionally carries
  /// `unread_count` here (see `NotificationService::getUserNotifications()`).
  /// Page 1 is cached for offline fallback.
  Future<({List<NotificationModel> items, PageMeta meta, int unreadCount})> list({int page = 1}) async {
    try {
      final envelope = await _client.getPage('/notifications', query: {'page': page});
      final items = envelope.list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      final unreadCount = envelope.meta?['unread_count'] as int? ?? 0;
      if (page == 1) {
        await _cache.write('notifications_list', {'items': envelope.list, 'unread_count': unreadCount});
      }
      return (items: items, meta: PageMeta.fromJson(envelope.meta), unreadCount: unreadCount);
    } on ApiException catch (e) {
      if (!e.isNetworkError || page != 1) rethrow;
      final cached = _cache.read('notifications_list');
      if (cached == null) rethrow;
      final map = Map<String, dynamic>.from(cached.data as Map);
      final items =
          (map['items'] as List).map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      return (
        items: items,
        meta: const PageMeta(currentPage: 1, lastPage: 1, perPage: 20, total: 0, hasMore: false),
        unreadCount: map['unread_count'] as int? ?? 0,
      );
    }
  }

  /// Synchronous read of the cached page-1 list (if any, within
  /// [OfflineCache.maxAge]) — lets [NotificationsController] paint it
  /// immediately and revalidate in the background, same role as
  /// `HomeApi.readCachedHomeScreen`.
  ({List<NotificationModel> items, int unreadCount})? readCachedList() {
    final cached = _cache.read('notifications_list');
    if (cached == null) return null;
    final map = Map<String, dynamic>.from(cached.data as Map);
    final items =
        (map['items'] as List).map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    return (items: items, unreadCount: map['unread_count'] as int? ?? 0);
  }

  Future<void> markRead(int id) => _client.patch('/notifications/$id/read');

  Future<void> markAllRead() => _client.post('/notifications/read-all');
}

@Riverpod(keepAlive: true)
NotificationsApi notificationsApi(NotificationsApiRef ref) =>
    NotificationsApi(ref.watch(apiClientProvider), ref.watch(offlineCacheProvider));
