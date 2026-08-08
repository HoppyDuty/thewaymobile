import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'hive_setup.dart';

part 'offline_cache.g.dart';

/// Generic JSON cache for "show this offline for weeks, not minutes" data
/// (Home dashboard, News, Notifications, ...) — distinct from the
/// short-TTL in-memory caching the backend already does; this is a local,
/// on-device copy so the app has *something* to show with zero network at
/// all, per `uiuxrules.md` §8 ("offline mode must feel like a first-class
/// state") and the "available offline for weeks" requirement.
///
/// Stored as plain maps in Hive (see `HiveSetup` for why no `@HiveType`
/// adapter is needed for simple JSON blobs like this).
class OfflineCache {
  OfflineCache(this._box);

  final dynamic _box;

  /// How long a cached entry is still considered worth showing at all.
  /// Past this, [read] returns null and the caller falls back to a normal
  /// loading/error state rather than showing very stale data.
  static const maxAge = Duration(days: 35);

  Future<void> write(String key, Object json) {
    return _box.put(key, {'data': json, 'cached_at': DateTime.now().toIso8601String()});
  }

  /// Returns the cached value (regardless of age, capped at [maxAge]) plus
  /// how old it is, or `null` if nothing is cached / it's past [maxAge].
  ({dynamic data, DateTime cachedAt})? read(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw as Map);
    final cachedAt = DateTime.tryParse(map['cached_at'] as String? ?? '');
    if (cachedAt == null) return null;
    if (DateTime.now().difference(cachedAt) > maxAge) return null;

    return (data: map['data'], cachedAt: cachedAt);
  }
}

@Riverpod(keepAlive: true)
OfflineCache offlineCache(OfflineCacheRef ref) => OfflineCache(HiveSetup.offlineCacheBox);
