# The Way Mobile — UI/UX & Engineering Rules

This is the permanent source of truth for the TheWay mobile app's visual and interaction
system. It supersedes the earlier working spec at `thewaybackend/docs/uiuxrules.md` (that
document was written before backend/mobile shared a parent folder and is preserved as
historical context, but this file is authoritative going forward for anything mobile-specific).
Every new screen must follow it. Do not invent per-screen visual rules.

Status column: **BUILT** = already implemented and verified in the current codebase.
**PARTIAL** = exists but inconsistently applied. **TODO** = not yet built.

---

## 1. Philosophy

TheWay must feel like a premium, fast, trustworthy educational product — not a generic
Flutter scaffold. Every screen answers, at a glance: *where am I, what matters, what can I
do, what just happened, what's next.* Clarity over decoration, consistency over novelty,
motion with purpose. (Full UX-law grounding — Jakob's/Fitts's/Hick's/Miller's Law, the
Doherty Threshold, Aesthetic-Usability Effect, Tesler's Law, Peak-End Rule — is in
`thewaybackend/docs/uiuxrules.md` §2 and still applies; not repeated here.)

## 2. Brand Identity — Blue + Gold + Clean Neutrals

**BUILT.** `lib/core/theme/app_colors.dart` — `brandBlue` (`#1A237E`) and `brandGold`
(`#D4AF37`) are deliberately identical to the backend's Filament admin panel colors
(`AdminPanelProvider::panel()`), so the product reads as one system across mobile and admin.
A full tonal ramp exists for both (`blue50…blue900`, `gold50…gold900`) for cases a Material
`ColorScheme` role doesn't cover — a badge fill, a chip border, a gold accent on a light card.

**Rule:** blue is the primary structural/action color (buttons, selected nav state, links,
primary progress). Gold is a restrained premium accent (badges, achievement/celebration
moments, a highlighted stat, an active streak) — never a full-screen background, never body
text on white (contrast), never applied to more than one or two elements per screen. Most of
the UI should read as clean neutrals with blue/gold as accents, not "everything blue and gold."

**Rule:** never hardcode a raw `Color(0x...)` in a screen or widget. Use:
- `Theme.of(context).colorScheme.*` for anything that must adapt to light/dark
  (background, surface, onSurface, outline, error) — this is seeded from `brandBlue`/
  `brandGold` via `ColorScheme.fromSeed`, so it already carries brand identity.
- `context.appColors.*` (`AppThemeExtension`) for success/warning/danger/info.
- `AppColors.blue*`/`AppColors.gold*` only when you need a specific fixed shade the
  `ColorScheme` doesn't expose (e.g. a badge that must be exactly gold200 in both themes).

## 3. Design Tokens

**BUILT**, all in `lib/core/theme/`:
- `app_colors.dart` — brand + tonal ramps (§2).
- `app_spacing.dart` — `AppSpacing.xs/sm/md/lg/xl/xxl` (4/8/16/24/32/48).
- `app_radius.dart` — `AppRadius.sm/md/lg/xl/pill` (8/14/18/24/999) + `BorderRadius` getters.
- `app_typography.dart` — full Material `TextTheme` on Google Fonts "Inter", explicit
  weight/height per style (display/headline/title/body/label — see §5).
- `app_motion.dart` — `AppDurations.fast/normal/slow` (150/250/400ms), `AppCurves`.
- `app_theme.dart` / `app_theme_extension.dart` — assembles the above into light/dark
  `ThemeData`, themes every stock Material component centrally (buttons, inputs, cards, nav
  bar, bottom sheets, snackbars, dividers).

**Rule:** a raw `EdgeInsets.all(13)`, a raw `BorderRadius.circular(10)`, or a raw
`TextStyle(fontSize: 15)` in screen code is a bug. Use the tokens above.

## 4. Iconography — Apple-Grade, One System

**Current state (PARTIAL → this phase's job to fix):** the app uses Material `Icons.*`
exclusively (155 call sites), with `cupertino_icons` declared in `pubspec.yaml` but **never
actually used** (dead dependency). This is internally consistent (one source, not a mix of
three icon packs) but reads as generic Android/Material, not the "Apple-grade" identity this
spec calls for.

**Direction:** introduce `lib/core/theme/app_icons.dart` — a single `AppIcons` class
mapping semantic names to icon data (`AppIcons.home`, `AppIcons.book`, `AppIcons.video`,
`AppIcons.cbt`, `AppIcons.profile`, `AppIcons.download`, `AppIcons.search`,
`AppIcons.settings`, …), so every call site references `AppIcons.x` rather than
`Icons.x` directly — this is what makes a future icon-set swap (e.g. to a licensed SF-Symbols-
style pack, or a custom SVG set) a one-file change instead of a 155-site find/replace.
Initial implementation uses Cupertino icons (already a zero-cost dependency, genuinely
Apple-styled, consistent stroke weight) as the glyph source, since introducing a paid/licensed
icon library is a product decision outside this audit's scope; the mapping layer means that
decision can change later without touching any screen. Every icon must have a deliberate
outlined (unselected) / filled (selected) pair where the platform convention calls for one
(tab bar, toggleable state) — do not mix filled and outlined arbitrarily within one context.

## 5. Typography

**BUILT.** `AppTypography.textTheme()` — Google Fonts "Inter", full scale (display → label),
explicit `FontWeight` per level, `height: 1.4` on body text for readability. Never introduce
a second font family or an ad hoc `TextStyle` — extend `AppTypography` if a new level is
genuinely needed.

## 6. Loading States — Three Levels

This is the most commonly misapplied rule; be precise about which level applies.

**Level 1 — Screen-specific shimmer/skeleton.** For *initial* page loads where the final
layout is known (a list, a detail page with a predictable structure). The skeleton's shape
must resemble the final layout closely enough to avoid layout shift. `HomeShimmer` already
exists (`lib/features/home/presentation/widgets/home_shimmer.dart`) as the reference
implementation — every major list/detail screen (CBT listing, Videos, Books, Profile, Search
results) needs its own purpose-built equivalent, not a shared generic shimmer box.
**Do not** shimmer content that loads near-instantly (cached data displayed immediately, per
§8) — shimmer is for the "no data yet, but we know the shape" state specifically.

**Level 2 — iOS-style indicator.** For short, bounded user actions: login submit, OTP verify,
save profile, retry, pull-to-refresh's own spinner. Use `CupertinoActivityIndicator`
(already imported where this matters), not a large Material `CircularProgressIndicator` —
the latter reads as Android, not premium. `AppButton`'s loading state should show this
inline (button stays its size, label replaced by the indicator), never a full-screen
blocking spinner for an action this short.

**Level 3 — Measurable progress.** For operations with a real, known progress value: video
download (`63%`), file upload. Show the actual number/progress bar, never an indeterminate
spinner when a determinate one is possible — `VideoDownloadController` already tracks byte
progress (`video_download_controller.dart`); the UI must surface it, not collapse it into a
generic "downloading…" spinner.

**Performance rule:** a shimmer implementation must not itself become the bottleneck — no
continuous animation on an off-screen widget, no expensive gradients/blurs repainting every
frame, no full-screen rebuild to update one shimmer tile. Reuse `AppShimmer`
(`lib/core/widgets/app_shimmer.dart`) as the primitive; build screen skeletons out of it
rather than hand-rolling new `AnimatedBuilder`s per screen.

## 7. Navigation

**BUILT — typed, animated, state-preserving.** `go_router` (`lib/core/router/app_router.dart`),
`StatefulShellRoute.indexedStack` for the 5 bottom-nav tabs (each tab keeps its own stack and
scroll position across switches — `lib/features/shell/main_shell.dart`). Custom transition
helpers (`buildPageWithTransition` = fade+slide, `buildModalPage` = slide-up) are used
everywhere instead of instant/default transitions. A single `redirect` callback layers
app-gate (version/maintenance) → auth-state → route decisions in one place
(`app_router.dart:97-127`).

**Gap to fix, not a rebuild:** most feature routes are inline path-string literals rather
than named constants in `AppRoute` (only pre-auth/gate routes are named today) — centralize
these as this phase touches each feature, don't do a single mechanical pass that touches
every file at once for its own sake.

## 8. Bottom Navigation — Floating

**Current state (PARTIAL → this phase's job to fix):** `MainShell` uses a stock Material 3
`NavigationBar`, full-width, `elevation: 0`, docked to the bottom edge — functionally correct
(preserves per-tab state, correct active/inactive icon swap) but visually a standard Material
bar, not the "floating, lightweight, premium" bar this spec calls for.

**Direction:** rebuild the bar's *container* as a floating, inset, rounded pill/capsule
(margin from all three edges, elevated card-like surface, `AppRadius.pill` or `xl`) while
keeping the underlying `NavigationBar`'s logic (or a thin custom equivalent) so tab-state
preservation and the existing `goBranch`/`initialLocation` behavior are unchanged. Respect
safe-area insets, must not shift/jump when the keyboard opens (only relevant screens push
the keyboard; the shell itself never should), touch targets stay ≥44×44dp, active tab state
must be unambiguous at a glance (icon fill + color, not color alone — accessibility, §14).

## 9. Splash & App Icon

**Asset:** `assets/images/logo.png` — The Way Educational Consult crest (graduation cap, "7"
mark, star, book motif, navy + gold + white) is the one approved logo. It is used, unmodified,
for the splash screen and as the source artwork for both platforms' launcher icons. No
placeholder, no redrawn/simplified version, no text-only substitute.

**Splash (current state PARTIAL → this phase's job):** `lib/features/splash/splash_screen.dart`
today is a bare centered logo + app name + generic `CircularProgressIndicator` — functionally
fine (the router's redirect logic drives all navigation; this screen has none of its own) but
visually inert. Rebuild as a minimal, brand-forward composition (logo + subtle premium entrance
motion, e.g. a short fade/scale-in, no looping animation, no artificial delay) that
**never blocks on network** — per `uiuxrules.md`'s startup-stage rule (backend doc §25):
native splash → critical init (Hive, secure-storage check) → app-version/gate check →
auth check → first useful screen. Nothing non-critical (analytics, cache cleanup, full CBT
delta-sync) may run before the first frame; defer it to after landing on Home.

**App icon (TODO — not yet configured):** no `flutter_launcher_icons` (or equivalent) config
exists in `pubspec.yaml` yet, and no generated `android/app/src/main/res/mipmap-*`/
`ios/Runner/Assets.xcassets/AppIcon.appiconset` artifacts derived from `logo.png` were found.
This phase adds `flutter_launcher_icons`, generates both platforms' full icon sets from
`assets/images/logo.png`, and verifies the logo's transparent padding is handled correctly
for iOS (which requires an opaque background, no alpha channel) vs Android adaptive icons
(which want a safe-zone-respecting foreground layer).

## 10. Error / Empty / Offline States

**BUILT as components, PARTIAL in coverage.** `lib/core/widgets/app_error_state.dart` and
`app_empty_state.dart` exist and are used on Home (confirmed) — extend the same components to
every list/detail screen rather than inventing new ones. Errors must never show a raw
`DioException`/`SocketException`/status code — `core/error/error_mapper.dart` already maps
technical errors to domain-level user messages; every screen's error branch must go through
it, never display `error.toString()` directly.

Offline is a first-class state, not an error: `AppOfflineBanner`
(`lib/core/widgets/app_offline_banner.dart`) is mounted globally once
(`lib/app.dart`) and debounces by 2s before appearing, so a blip doesn't flash it. When cached
data exists, show it with the banner, never replace the screen with a blocking "no internet"
error — see §11 for which screens currently have a cache to fall back to.

## 11. Offline-First Architecture (as it actually exists today — not aspirational)

This section reflects the current, real implementation, confirmed by direct code audit. It is
the honest baseline this phase builds on — read it before assuming a feature is or isn't
offline-capable.

**Local storage:** Hive CE (`hive_ce`/`hive_ce_flutter`), not sqflite/drift/isar. Boxes:
`auth_box` (cached user profile), `settings_box` (theme, onboarding flag, misc scalars),
`offline_cache_box` (generic JSON cache, see below), plus typed CBT boxes (exam types,
subjects, questions, passage groups, offline sessions, delta checkpoints, pending-sync queue),
`video_downloads_box`, `saved_books_box`. `flutter_secure_storage` holds exactly two things:
the JWT access token and the device fingerprint (the fingerprint deliberately survives
logout, to keep the 30-day new-device cooldown working across logins on the same device).

**CBT has a genuinely sophisticated offline engine already** — this is the pattern to
generalize, not rebuild:
- Real delta sync (`cbt_sync_service.dart`) against `/cbt/questions/delta`, with a per-exam-type
  checkpoint (last-synced-at + checksum), pull-until-exhausted pagination, and deletion
  handling for questions removed server-side.
- Exam-session progress is persisted to Hive on every answer/bookmark tap, plus a forced
  15-second timer checkpoint — an app kill loses at most ~15s of timer state and zero answer
  data.
- A durable, idempotent pending-operation queue (`offline_queue_service.dart`) keyed by a
  client-generated `offline_uuid` that matches the backend's `sync_operation_logs.offline_uuid`
  dedup key — submissions made offline are queued, flushed on reconnect, and the backend's
  `already_synced` response is handled correctly (no duplicate submission on retry).
- Offline question-building and offline scoring fall back to a full client-side port of the
  backend's logic when the network is unavailable at session-start/submit time.

**Everything else (Home, Videos, Books, News, Notifications) is much weaker** — a generic
`OfflineCache` (`lib/core/storage/offline_cache.dart`) that is network-first with a
cache-only-on-failure fallback (not stale-while-revalidate), a flat 35-day TTL, no
versioning, no background revalidation. **Profile has no offline story at all** — every call
hits the network with no fallback.

**Connectivity detection is centralized in principle** (`connectivityProvider`,
`lib/core/connectivity/connectivity_provider.dart`) but in practice only two things consume
it today: the offline banner, and CBT's `SyncManager` — and `SyncManager` only starts
listening once something has caused it to be built (currently only visiting the CBT tab), so
a session that never opens CBT never triggers a reconnect-sync at all. **There is no
background/OS-level sync** (no WorkManager/background_fetch) — everything is
foreground-only, provider-lifecycle-triggered.

**This phase's offline-architecture work:** (a) make `SyncManager`-equivalent reconnect
listening apply app-wide, not gated behind a tab visit — likely by promoting connectivity-
triggered refresh to something built at app startup rather than lazily; (b) give Home/Videos/
Books/News a real stale-while-revalidate cache instead of network-first-fallback, so cached
content renders *immediately* while a background refresh happens, per §6's Doherty-Threshold
goal; (c) give Profile at least a basic cache for its own display data. None of this touches
CBT's engine, which is already correct.

## 12. Video & Book Downloads

**BUILT, working, with known gaps.** Both features independently implement: queue → poll/
direct-URL → `Dio` download with progress → Hive metadata record → lazy expired-record
cleanup on read. Deterministic file paths (`{lessonId}_{quality}.mp4`,
`{bookId}.pdf` under `getApplicationDocumentsDirectory()`) mean a re-download of the same
item overwrites rather than duplicates.

**Gaps to close:** (a) no orphan-file reconciliation — if a Hive write fails after the file
write succeeds (or vice versa), the file/record pair can desync; a startup or on-demand
reconciliation pass should exist. (b) Download state today is implicit in whether a
`DownloadedVideoModel`/`SavedBookModel` record exists plus polling status — this phase should
make the state explicit per §17 of the driving spec (`notDownloaded / queued / downloading /
failed / completed`), surfaced consistently in the UI rather than inferred.

**Confirmed:** once a video/book is downloaded, opening it does **not** require the network —
`LocalVideoPlayerScreen`/`PdfReaderScreen` read the local file path directly.

## 13. yt-dlp / Video Processing Pipeline (backend)

Out of this mobile-focused pass's direct implementation scope, but load-bearing for §12 — see
the tracked follow-up in `thewaybackend/PRODUCTION_READINESS.md` for the backend-side
video-processing audit (queue behavior, `yt-dlp` invocation safety, storage/cleanup). Any
finding there that changes the download-status polling contract (`/videos/downloads/{token}/
status` response shape) must be reflected in `video_download_controller.dart`.

## 14. Accessibility

Minimum touch target 44×44dp (Fitts's Law, backend doc §2). Never communicate state through
color alone — pair with an icon and/or text (e.g. an error is red **and** has an error icon
**and** an error message, not just red). Support text scaling without clipping/overflow;
semantic labels on interactive icons (a `AppIcons.download` button needs a
`Semantics`/tooltip label, not just a bare `IconButton`). Respect reduced-motion where the
platform signals it.

## 15. Component Architecture

**BUILT, keep extending.** `lib/core/widgets/` already has `app_button.dart`,
`app_text_field.dart`, `app_empty_state.dart`, `app_error_state.dart`, `app_shimmer.dart`,
`app_network_image.dart`, `app_logo.dart`, `app_offline_banner.dart`, `app_section_header.dart`,
`loading_indicator.dart`, `rive_animation_view.dart` — reused across nearly every screen
already (this is not duplicated UI logic). Add to this set rather than building one-off
widgets per screen: a new screen needing a card/badge/chip pattern should get an `AppCard`/
`AppBadge`/`AppChip` added here if one doesn't exist, not an inline `Container` with hand-set
decoration.

## 16. Performance

Profile with Flutter DevTools before optimizing anything — do not guess. `const` constructors
throughout, lazy lists (`ListView.builder`, not `ListView(children: [...])` for anything
unbounded), `cached_network_image` for all remote images (already a dependency — ensure every
`Image.network` call site actually uses it, not a raw `Image.network`), scoped Riverpod
`select()` where a widget only needs one field of a larger state object.

## 17. Final Quality Gate (per screen, before considering it done)

- No overflow/clipped content at default and 200% text scale.
- Loading/empty/error/offline states all implemented and visually distinct (§6, §10).
- Icons come from `AppIcons` (§4), not raw `Icons.*`.
- Colors come from `Theme.of(context)`/`context.appColors`/`AppColors.blue*`/`gold*` — no
  raw `Color(0x...)` literals.
- Spacing/radius/typography come from the tokens in §3 — no magic numbers.
- Cached data (where the feature has a cache) renders immediately; network is not required to
  see previously-seen content.
- No `print()`/`debugPrint()` left in, no `TODO` comments describing unfinished behavior.
