import 'dart:async';

/// The "seed from cache, then background-refresh" half of stale-while-
/// revalidate for `AsyncNotifier`-based controllers (`UI_UX_RULES.md` §11).
///
/// Replaces the old network-first/cache-on-failure pattern — which only
/// shows cached data when the network call has already failed — with cache
/// shown *immediately* (no network wait at all) while a fresh copy loads
/// silently behind it. If [cached] is `null` (nothing cached yet), this
/// just awaits [fetch] directly, identical to the old behavior.
///
/// Callers pass [fetch] itself as the thing that both hits the network and
/// keeps the on-disk cache current on success (every `*Api` method already
/// does this) — this helper only adds the "seed now, revalidate after"
/// scheduling around it, not a second caching layer.
Future<T> seedAndRevalidate<T>({
  required T? cached,
  required Future<T> Function() fetch,
  required void Function(T) onRevalidated,
}) async {
  if (cached == null) return fetch();

  unawaited(_revalidate(fetch, onRevalidated));
  return cached;
}

Future<void> _revalidate<T>(Future<T> Function() fetch, void Function(T) onRevalidated) async {
  // `state` isn't assignable until the notifier's own `build()` call has
  // returned — yield one event-loop turn so that's guaranteed to have
  // happened before `onRevalidated` (which sets `state`) runs.
  await Future<void>.delayed(Duration.zero);
  try {
    onRevalidated(await fetch());
  } catch (_) {
    // Best-effort background refresh — the stale value already rendered
    // stays on screen; a silent revalidate failure isn't a user-facing
    // error (`UI_UX_RULES.md` §10 — never blow away useful content for
    // an error the user didn't ask about).
  }
}
