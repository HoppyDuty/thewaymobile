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

/// Runs [parse] (typically a `.fromJson` call on a value just read from
/// [OfflineCache]) and swallows any failure, returning `null` instead.
///
/// A cache entry can go stale in ways [OfflineCache.read] can't detect —
/// written under an older app version whose model shape has since changed,
/// or left partially written by a crash mid-write. Without this, that one
/// bad entry throws straight out of a `*Controller.build()` (cache reads
/// happen synchronously, before any network fetch) and permanently bricks
/// that screen with "Something went wrong" until the app's storage is
/// cleared. Treating a parse failure the same as "nothing cached" lets the
/// caller fall through to loading state / a real network fetch instead.
T? tryParseCached<T>(T Function() parse) {
  try {
    return parse();
  } catch (_) {
    return null;
  }
}

@Riverpod(keepAlive: true)
OfflineCache offlineCache(OfflineCacheRef ref) => OfflineCache(HiveSetup.offlineCacheBox);
