import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_setup.dart';
import 'models/dictionary_entry.dart';

part 'dictionary_local_store.g.dart';

/// Offline persistence for the Dictionary feature — recent searches and a
/// progressively-growing cache of every successfully looked-up word.
/// Neither existed before (the feature was online-only); this uses the
/// existing untyped `settingsBox` rather than adding new typed Hive boxes,
/// since both values are small, simple JSON-shaped data with no need for
/// generated type adapters.
class DictionaryLocalStore {
  static const _cacheKey = 'dictionary_lookup_cache';
  static const _recentKey = 'dictionary_recent_searches';
  static const _maxRecent = 20;
  static const _maxCached = 200;

  /// A previously-cached result for [word], or `null` if never looked up
  /// (or looked up before this feature existed). Callers should try this
  /// before hitting the network.
  List<DictionaryEntry>? read(String word) {
    final cache = _cache();
    final raw = cache[_normalize(word)] as List<dynamic>?;
    if (raw == null) return null;
    return raw.map((e) => DictionaryEntry.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  /// Persists a successful lookup so the next search for the same word
  /// never needs the network. Capped at [_maxCached] entries (oldest
  /// evicted first) so this can't grow unbounded over the life of the app.
  Future<void> write(String word, List<DictionaryEntry> entries) async {
    final cache = _cache();
    final key = _normalize(word);
    cache.remove(key); // re-insert at the end = most-recently-used
    cache[key] = entries.map((e) => e.toJson()).toList();

    while (cache.length > _maxCached) {
      cache.remove(cache.keys.first);
    }

    await HiveSetup.settingsBox.put(_cacheKey, cache);
  }

  /// Most-recent-first, deduplicated (case-insensitive).
  List<String> recentSearches() {
    final raw = HiveSetup.settingsBox.get(_recentKey) as List<dynamic>?;
    return raw?.cast<String>() ?? const [];
  }

  Future<void> recordSearch(String word) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...recentSearches().where((w) => w.toLowerCase() != trimmed.toLowerCase()),
    ];
    if (updated.length > _maxRecent) updated.removeRange(_maxRecent, updated.length);

    await HiveSetup.settingsBox.put(_recentKey, updated);
  }

  Future<void> clearRecentSearches() async {
    await HiveSetup.settingsBox.delete(_recentKey);
  }

  Map<dynamic, dynamic> _cache() {
    final raw = HiveSetup.settingsBox.get(_cacheKey) as Map<dynamic, dynamic>?;
    return raw == null ? {} : Map<dynamic, dynamic>.from(raw);
  }

  String _normalize(String word) => word.trim().toLowerCase();
}

@Riverpod(keepAlive: true)
DictionaryLocalStore dictionaryLocalStore(DictionaryLocalStoreRef ref) => DictionaryLocalStore();
