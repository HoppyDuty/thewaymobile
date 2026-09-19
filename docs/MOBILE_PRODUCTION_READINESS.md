# The Way Mobile — Production Readiness

Living document, updated as each rebuild milestone lands. See `docs/UI_UX_RULES.md` for the
design/engineering spec this work follows. Status legend: **VERIFIED** = built and confirmed
(analyzer/build/test). **NOT VERIFIED** = not yet checked in this environment (no
emulator/device available here — see note at the bottom).

---

## Milestone 1 — Design system foundation, floating nav, splash, app icon (this pass)

### What changed
- `docs/UI_UX_RULES.md` — new, permanent design/engineering rules doc (supersedes
  `thewaybackend/docs/uiuxrules.md` for mobile-specific decisions going forward).
- `lib/core/theme/app_colors.dart` — added a full blue/gold tonal ramp (`blue50…blue900`,
  `gold50…gold900`) on top of the existing `brandBlue`/`brandGold` seed colors (unchanged —
  they're deliberately synced with the backend's Filament admin panel).
- `lib/core/theme/app_icons.dart` — new `AppIcons` class, a single mapping layer over
  Cupertino icon glyphs, so icon-set changes later don't require touching every screen.
  Currently covers the 5 nav destinations + the most common content/chrome/status icons; the
  other ~150 `Icons.*` call sites across the app are not yet migrated (see Remaining Work).
- `lib/core/widgets/floating_nav_bar.dart` — new `FloatingNavBar` widget: an inset, rounded,
  elevated bar replacing the stock Material `NavigationBar`. Purely presentational — the
  actual navigation logic (`StatefulNavigationShell.goBranch`/`initialLocation`) in
  `lib/features/shell/main_shell.dart` is unchanged, so per-tab state preservation still works
  exactly as before.
- `lib/features/splash/splash_screen.dart` — rebuilt with a short (520ms), non-looping
  fade+scale entrance for the real logo, and a `CupertinoActivityIndicator` in place of the
  previous generic Material spinner. No navigation logic was added or changed — the router's
  redirect chain still drives everything, unchanged.
- App icon generation: added `flutter_launcher_icons` (dev dependency), configured against
  `assets/images/logo.png` (the one approved brand asset — not redrawn or replaced), with
  `remove_alpha_ios: true` since the source has transparency and iOS requires an opaque icon.
  Ran the generator — Android and iOS icon sets are regenerated from the real logo.
- Fixed app display name: Android's `AndroidManifest.xml` had `android:label="theway_mobile"`
  (the raw project slug, would show under the icon on a device's home screen) and iOS's
  `Info.plist` had `CFBundleDisplayName`/`CFBundleName` = "Theway Mobile"/"theway_mobile" —
  both corrected to "The Way", matching the backend's `APP_NAME` and the splash screen text.

### Verification performed
- `flutter analyze` — **VERIFIED**, 0 new issues (the 3 pre-existing issues — 2 SDK-level
  `Radio` deprecation warnings in `payment_sheet.dart`, 1 expected "`.env` doesn't exist until
  a developer copies `.env.example`" warning — are unrelated to this milestone and unchanged).
- `dart run flutter_launcher_icons` — **VERIFIED**, completed successfully, regenerated both
  platforms' icon sets from `assets/images/logo.png`.
- `flutter build apk --debug` — **FAILED, but root-caused to a pre-existing, unrelated issue,
  not this milestone's changes.** The `rive_native` package's build-time native-asset-download
  step (`Gradle task :rive_native:runRiveNativeSetup`) shells out to PowerShell's
  `Expand-Archive` (`rive_native-0.1.9/bin/setup.dart:569-573`) to unzip its downloaded
  binaries, and that invocation breaks specifically because this machine's Windows user
  profile path contains a space (`C:\Users\ASIFAT HAMID\...`) — PowerShell's argument parsing
  splits the path and throws `ParameterBindingException: PositionalParameterNotFound`. This
  would happen on **any** Android build on this machine regardless of what else changed;
  confirmed by reading the exact failing command in the vendored package source, and it fires
  before any of this app's own code is compiled. **This is a real, CRITICAL finding for the
  team** (it will hit any developer/CI machine whose Windows path contains a space) but not
  something to patch inside `pub-cache` (overwritten on the next `pub get`, not durable) — see
  Remaining Work / Known Limitations for suggested remediation.
- **NOT VERIFIED**: visual appearance on a real device/emulator, and an actual successful
  Android/iOS build — blocked by the `rive_native` issue above in this environment. The
  animation timing, floating-bar sizing/margins, and icon glyph choices should be eyeballed on
  a device (or a machine/CI path without a space) before considering this milestone fully
  signed off.

### Explicitly not touched in this milestone
Per `UI_UX_RULES.md`'s own philosophy (build the foundation, then apply it feature-by-feature
rather than one mechanical pass touching everything): auth screens, Home's section widgets,
CBT, Videos, Books, Profile, onboarding, and the remaining ~150 non-nav icon call sites are
unchanged. They already build on the *existing* (pre-this-milestone) design tokens correctly
— see the architecture inventory below — so nothing is broken, but they don't yet reflect the
floating-nav-bar-era polish or the `AppIcons` mapping.

---

## Milestone 2 — Auth screens (Login, Register, OTP verify, Forgot/Reset Password)

### What changed
- New shared `lib/core/widgets/app_inline_error.dart` (`AppInlineError`) — extracted from a
  private `_InlineError` class that existed only in `register_screen.dart` and wasn't reused.
  Now used consistently across all 4 forms (Login, Register, Forgot Password, Reset Password)
  and OTP Verify, replacing plain red `Text(_errorText!, ...)` calls that relied on color alone
  (`UI_UX_RULES.md` §14 accessibility rule).
- New `lib/core/widgets/google_logo_mark.dart` (`GoogleLogoMark`) — replaces
  `Icons.g_mobiledata_rounded` on the "Continue with Google" button. That icon is Material's
  mobile-network-signal glyph, not a Google mark at all — a real, pre-existing bug, not a
  stylistic nitpick. Replaced with a minimal "G" monogram in Google's brand blue rather than a
  hand-drawn multi-color logomark that can't be visually verified without a device.
- `AppButton`'s loading state now uses `CupertinoActivityIndicator` instead of a Material
  `CircularProgressIndicator` (`UI_UX_RULES.md` §6 Level 2) — since `AppButton` is the one
  button component used app-wide, this one change makes every primary-action loading state in
  the app consistent, not just auth.
- `OtpVerifyScreen`'s separate full-size `CircularProgressIndicator()` shown below the OTP
  boxes while verifying is now a `CupertinoActivityIndicator`, matching the same rule.
- **Duplicate-submission guards added** (explicitly required by the driving spec's auth
  section): `_submit()`/`_verify()`/`_resend()`/`_signInWithGoogle()` across all 5 auth
  screens now early-return if already in flight, instead of relying solely on the button's own
  disabled-while-loading state (which doesn't protect against other trigger paths, e.g. the
  OTP input's `onCompleted` firing again).

### Verification performed
- `flutter analyze` — **VERIFIED**, 0 new issues, whole-project run.
- `flutter build apk --debug` — still blocked by the `rive_native` issue (see below); not
  re-attempted for this milestone since the blocker is unrelated to auth and unchanged.
- **NOT VERIFIED**: visual appearance / actual OTP-entry and Google sign-in flow against a real
  backend on a device (none available in this environment).

### rive_native blocker — follow-up attempted, not resolved
Per your direction, bumped `rive: ^0.14.9 → ^0.14.11` and (transitively) `rive_native: 0.1.9 →
0.1.11` (the latest available per `flutter pub outdated`). **This did not fix the build
blocker** — confirmed by reading `rive_native-0.1.11/bin/setup.dart:569-576` directly: the
exact same unquoted `Process.run('powershell', ['Expand-Archive', '-Path', zipFilePath, ...])`
call is still there, byte-for-byte identical to 0.1.9. The bug is unfixed upstream as of the
latest release. Since the version bump was the option you chose and it didn't pan out, this
needs a decision on one of the other paths (drop the dependency until onboarding has real
`.riv` content — `assets/rive/` is still empty aside from `.gitkeep` — or build from a path
without a space in it) rather than me picking one unilaterally.

---

## rive_native blocker — resolved

Per your decision, removed `rive`/`rive_native` entirely (`pubspec.yaml`), since no `.riv`
files were ever shipped (`RiveAnimationView` was always hitting its own fallback icon).
Deleted `lib/core/widgets/rive_animation_view.dart`; `onboarding_screen.dart`/
`onboarding_data.dart` now show the fallback icon directly (functionally identical to before
— the animation was never actually rendering).

**Verified: this fixed it.** A fresh `flutter build apk --debug` progressed completely past
the `:rive_native:runRiveNativeSetup` step that was failing before. It now fails at a
**different, unrelated point**: downloading `pdfium-android` (used by `flutter_pdfview`, the
PDF/book reader) times out with a TLS handshake failure against Maven Central
(`repo.maven.apache.org`) — `Could not get resource ... Remote host terminated the handshake`.
This is a network/sandbox limitation of *this development environment* (outbound HTTPS to
Maven Central being blocked or TLS-intercepted), not a code or dependency defect — a normal
device/CI environment with standard internet access should not hit this. **Still not verified:
an actual successful build**, but the specific blocker you asked me to fix is confirmed fixed.

---

## Milestone 3 — Home screen polish

### What changed
- **Leaderboard gold accent**: top-3 rank badges now use `AppColors.gold100`/`gold800`
  instead of the generic `primaryContainer` — a direct, restrained application of the "gold =
  achievement/highlight" rule (`UI_UX_RULES.md` §2), applied only to the 3 elements it's
  actually meaningful for for on this screen.
- **Carousel readability fix**: added a bottom-anchored gradient scrim behind the carousel's
  overlay title/subtitle text. Previously plain white text sat directly on arbitrary
  admin-uploaded slide images with no guaranteed contrast — a real accessibility gap, not
  just a style preference.
- **Icon migration** (first real screens moved onto `AppIcons`, per the plan in Milestone 1):
  `GreetingHeader`'s notification bell (now also correctly swaps to the filled/active variant
  when there are unread notifications, which it didn't do before), `ContinueLearningSection`'s
  per-content-type icon, and `QuickActionsSection`'s 5 action icons.

### Verification performed
- `flutter analyze` — **VERIFIED**, 0 new issues (whole project and `lib/features/home`
  specifically both clean).
- **NOT VERIFIED**: visual appearance (gradient scrim opacity/stops, gold contrast) on a real
  device — these were reasoned about from the token values and Material contrast guidelines,
  not eyeballed.

### Not touched in this pass
Home's underlying data flow, caching, and state architecture (`home_controller.dart`,
`HomeShimmer`, the `OfflineCache`-based fallback) were left alone — they're already correct
per the Milestone 1 architecture audit. This pass was visual/accessibility polish only, plus
the icon-migration pattern now established for future screens to follow.

---

## Milestone 4 — CBT icon migration (exam flow + widgets)

### What changed
- `lib/core/theme/app_icons.dart` — extended with the glyphs CBT needed:
  `refresh`, `unlock`, `play`, `list`, `calculator` (`CupertinoIcons.number_square` — Cupertino's
  icon font has no literal calculator glyph, this is the closest one-system stand-in), `factCheck`,
  `sync`, `quiz`, plus content icons `checklist`, `history`, `practice` for the exam-mode cards.
  Cross-checked every new mapping against `flutter/src/cupertino/icons.dart` directly (not
  guessed) before wiring it in.
- All 9 CBT screens (`exam_types_screen`, `mode_selection_screen`, `subject_selection_screen` —
  no icons needed, `topic_selection_screen`, `session_setup_screen`, `exam_screen`,
  `result_screen`, `review_screen`, `bookmarks_screen`) and 5 widgets
  (`question_card`, `exam_type_picker_sheet`, `sync_badge`, plus `cbt_flow_args.dart`'s
  `ExamModeInfo` icons — `calculator_sheet`/`ios_number_picker` had no `Icons.*` to migrate) moved
  off raw `Icons.*` onto `AppIcons.*`. This is the CBT slice of Remaining-work item 8.
- **Loading states corrected to §6 Level 2**: `exam_screen.dart` (initial session load + the
  brief transition into the result screen), `result_screen.dart` (waiting on the result to land
  in state), `review_screen.dart` (waiting on session state) all used a bare Material
  `CircularProgressIndicator()` for what is a short, near-instant local-computation wait (CBT
  reads from Hive, not network) — switched to `CupertinoActivityIndicator`, matching the pattern
  `AppButton` already established. `SyncBadge`'s small in-progress spinner got the same fix.
- **Added the bookmark toggle's missing accessibility label** on `QuestionCard` (§14 — every
  interactive icon needs a semantic label, this one had none before).
- **Restrained gold "achievement" accent** on `ResultScreen` (`UI_UX_RULES.md` §2 — gold is
  reserved for celebration moments, this is a real one): when the score crosses the existing
  70%-celebration threshold (`_celebrationThresholdPercent`, already used to trigger confetti),
  the score ring and percentage text switch from `colorScheme.primary` to `AppColors.gold500`,
  and the confetti burst now uses the brand blue/gold palette explicitly instead of the
  `confetti` package's random default colors. Below the threshold, nothing changed — still
  primary blue, no gold anywhere else in CBT.

### Verification performed
- `flutter analyze lib/features/cbt lib/core/theme/app_icons.dart` — **VERIFIED**, 0 issues.
- `flutter analyze` (whole project) — **VERIFIED**, only the 3 pre-existing unrelated issues
  from Milestone 1 (2 `Radio` deprecation warnings in `payment_sheet.dart`, the expected missing
  `.env` asset warning).
- **NOT VERIFIED**: visual appearance (gold ring/confetti coloring, new icon glyphs, calculator
  icon substitution) on a real device — no emulator available in this environment.

### Not touched in this pass
CBT's offline engine (`cbt_sync_service.dart`, `offline_queue_service.dart`,
`local_scoring_service.dart`, `offline_question_builder.dart`) — already correct per the
Milestone 1 architecture audit, not part of a visual/icon pass. No new widgets were introduced;
this was polish on the existing, already-solid screen structure (all 9 screens were already
using `AppSpacing`/`AppRadius`/theme-role colors correctly — the gap was specifically icons,
loading-indicator level, and the missing celebration accent).

---

## Milestone 5 — Icon migration: Books, Dictionary, Notifications, Payments, Video, shared widgets

### What changed
Continued the `AppIcons` migration (Milestones 1/3/4) into the remaining feature screens —
`book_detail_screen`, `books_list_screen`, `my_books_screen`, `dictionary_screen`,
`notifications_screen`, `payment_webview_screen`, `payment_sheet`, `local_video_player_screen`,
`video_course_detail_screen`, `video_courses_screen`, `video_downloads_screen`,
`video_player_screen` — plus the shared core widgets most screens depend on
(`app_empty_state`, `app_error_state`, `app_inline_error`, `app_network_image`,
`app_offline_banner`, and the app-gate `force_update_screen`/`maintenance_screen`). Expanded
`AppIcons` with the additional glyphs these needed (`checklist`, `history`, `practice`,
`leaderboard`, `systemUpdate`, `maintenance`, `creditCard`, `wallet`, `bank`, `copy`, `chat`,
`delete`, `playOutline`, `pauseCircle`, `lock`, `quiz`, and others) rather than falling back to
raw `Icons.*`/`CupertinoIcons.*` at individual call sites — keeping the single-mapping-file
promise from Milestone 1 intact as coverage grows.

### Verification performed
- `flutter analyze` — **VERIFIED**, 0 new issues, whole-project run.

With this pass plus the concurrent News/Shepherd migration landing alongside it, icon
migration now covers Home, Auth, CBT, Books, Dictionary, Notifications, Payments, Video, News,
Shepherd, and the shared widget layer — the large majority of the app. Remaining unmigrated
call sites are concentrated in Profile (not yet touched by any milestone) and a handful of
screens with genuinely one-off icon needs.

---

## Milestone 6 — Unify the premium "unlock" paywall card (CBT, Videos, Books)

### What changed
CBT's exam-type unlock prompt, the video-course unlock prompt, and the book unlock prompt were
three independently-styled but structurally identical `Card`+`ListTile` blocks (icon, title,
optional subtitle, chevron, tap-to-pay), each using a generic Material `tertiaryContainer`
role. Extracted a shared `lib/core/widgets/app_unlock_card.dart` (`AppUnlockCard`) and wired all
three call sites (`mode_selection_screen.dart`, `video_course_detail_screen.dart`,
`book_detail_screen.dart`) onto it — this is exactly the kind of cross-feature duplication
`UI_UX_RULES.md` §15 calls out ("a new screen needing a card/badge/chip pattern should get a
shared component added, not an inline one-off").

At the same time, gave it the brand gold accent (`AppColors.gold50` background, `gold200`
border, `gold800`/`gold900` text/icon) instead of the generic `tertiaryContainer` — unlocking
premium content is precisely the kind of restrained "premium moment" `UI_UX_RULES.md` §2
reserves gold for (badges, achievement/celebration, a highlighted premium action), not
decoration for its own sake. It's now the second deliberate gold application in the app
(after the Home leaderboard's top-3 badges in Milestone 3), both narrow and purposeful.

### Verification performed
- `flutter analyze` — **VERIFIED**, 0 new issues, whole-project run.
- **NOT VERIFIED**: visual appearance/contrast of the gold treatment on a real device.

---

## Milestone 7 — Profile icon migration; gold streak accent

Profile's remaining screens (delete_account, edit_profile, payment_history, purchases, stats)
migrated onto `AppIcons`, completing icon-migration coverage across the entire app. On
`profile_screen.dart`, replaced the inline "🔥" emoji on the streak stat with `AppIcons.practice`
(a flame glyph) in the brand gold accent — a live streak is exactly the achievement moment
`UI_UX_RULES.md` §2 names as an example gold use case, and an icon renders consistently instead
of depending on the platform's emoji font. Also added spacing between the three stat cards,
which previously sat edge-to-edge with no gap. Verified: `flutter analyze` clean.

Also removed two confirmed-dead files in this pass: `LoadingIndicator` (the last remaining bare
Material `CircularProgressIndicator` in the codebase — but since nothing referenced it anywhere,
deleting it was the correct fix, not migrating it) and `ComingSoonPlaceholder` (a leftover
stand-in from before all 5 bottom-nav tabs were built out).

---

## Milestone 8 — Stale-while-revalidate caching app-wide; reconnect coordinator

The offline-architecture upgrade flagged as remaining work since Milestone 1 (§11). Full detail
in the commit message (`633fb6f`) — summary:

- New shared `seedAndRevalidate()` helper (`core/storage/stale_while_revalidate.dart`) replaces
  the old network-first/cache-on-failure pattern with cache shown **immediately** while a fresh
  copy loads silently behind it, applied to Home, Leaderboard, Books, Videos, News, Profile, and
  Notifications.
- New `AppReconnectCoordinator` (`lib/app_reconnect_coordinator.dart`) fixes the exact gap
  identified in Milestone 1: CBT's `SyncManager` only ever started listening for reconnects once
  something had built it (in practice, only after visiting the CBT tab). The coordinator existed
  but wasn't watched anywhere — **the fix was wiring `ref.watch(appReconnectCoordinatorProvider)`
  into `TheWayApp`'s root** (`app.dart`), which is the one line that actually activates it. On
  every offline→online transition it now triggers CBT's sync and invalidates Home/Leaderboard/
  Video/Books/News/Profile.

Verified: `dart run build_runner build` (clean regeneration of all `.g.dart` files) + `flutter
analyze` clean across the whole project. **Not verified**: actual reconnect behavior on a device
— no emulator available in this environment; the connectivity-toggle flow in particular should
be exercised on a real device before considering this fully signed off.

---

## Architecture inventory (confirmed by direct code audit, not assumed)

**Screens:** 48 distinct screens/dialogs/sheets across 13 features (auth, home, CBT, video,
books, profile, notifications, news, shepherd/AI-tutor, payments, dictionary, onboarding,
app-version/gate). Full inventory available in this session's research — ask if you want it
re-materialized as a table in this doc.

**Navigation:** `go_router` with a typed `StatefulShellRoute.indexedStack` for the 5 main
tabs, a single centralized auth/gate `redirect` callback, and custom animated page
transitions used everywhere (no default instant `MaterialPageRoute`). Solid; not rebuilt.

**State management:** Riverpod (code-gen `@riverpod` style) used exclusively and consistently
— zero competing state-management packages found anywhere in the codebase.

**Design tokens:** already centralized before this milestone (colors, spacing, radius,
typography, motion durations/curves) — genuinely disciplined, not scattered. This milestone
extended rather than replaced it.

**Offline architecture:** CBT has a real, sophisticated offline-first engine already (delta
sync with checkpoints, a durable idempotent pending-operation queue keyed by `offline_uuid`
matching the backend's dedup key, autosave-on-every-answer exam progress). Home/Videos/Books/
News have a much weaker network-first/cache-on-failure fallback with a flat 35-day TTL and no
revalidation. Profile has no offline story at all. Full detail in `UI_UX_RULES.md` §11.

**Video/book downloads:** working end-to-end (queue/poll or direct-URL → progress-tracked
download → Hive metadata → deterministic local file path), confirmed offline playback doesn't
require network once downloaded. Gaps: no orphan-file reconciliation, download state is
implicit rather than an explicit enum. Detail in `UI_UX_RULES.md` §12.

---

## Remaining work (not started, scoped for future milestones)

Each of these is its own milestone per the driving spec's own instruction ("implement → test
→ review → commit" per feature, not one giant commit):

1. **Auth screens** (Login, Register, OTP verify, Forgot/Reset Password) — visual rebuild +
   migrate to `AppIcons`.
2. **Home screen** — rebuild section widgets (carousel, quick actions, continue-learning,
   leaderboard, news preview) for visual polish; migrate icons.
3. ~~**CBT** — visual rebuild of exam-type/mode/subject/topic selection, the exam-taking screen
   itself (highest-stakes UX in the app), results/review/bookmarks.~~ — **DONE** (Milestone 4):
   the flow's structure/tokens/accessibility were already solid (confirmed by direct audit, not
   assumed), so this landed as icon migration + loading-state-level correction + a gold
   celebration accent, not a ground-up rebuild — see Milestone 4 for the reasoning.
4. **Videos** — listing/detail/player/downloads visual rebuild.
5. **Books** — listing/detail/reader/saved visual rebuild.
6. **Profile** — hub + edit/stats/purchases/payments/preferences visual rebuild.
7. **Onboarding** — verify Rive assets actually exist and render (research flagged
   `assets/rive/` contains only a `.gitkeep`, no real `.riv` files — the onboarding screen may
   currently be silently falling back to a plain icon).
8. **Icon migration** — move the remaining `Icons.*` call sites onto `AppIcons`, expanding the
   mapping as needed per screen. CBT's ~20 sites done in Milestone 4; still open across
   Videos/Books/Profile/onboarding/shell/core widgets — recount at the start of that pass since
   Milestones 3 and 4 already reduced the original ~150 estimate.
9. **Offline-architecture work** described in `UI_UX_RULES.md` §11: app-wide reconnect
   listening (not gated behind visiting the CBT tab), stale-while-revalidate caching for
   Home/Videos/Books/News, a basic cache for Profile.
10. **Centralize route names** — most feature routes are inline path-string literals; only
    pre-auth/gate routes are named `AppRoute` constants today.
11. **Backend yt-dlp / video-processing pipeline audit** — out of mobile's direct scope; see
    `thewaybackend/PRODUCTION_READINESS.md` for the backend-side follow-up needed.
12. ~~CRITICAL: fix the `rive_native` Android build blocker~~ — **RESOLVED** (Milestone 3):
    removed the dependency; verified the build gets past that step now. A new, unrelated,
    environment-specific network issue (Maven Central TLS handshake) is documented above.

## Known limitations of this audit pass

- No Android emulator, iOS simulator, or physical device was available in this environment —
  everything above was verified via static analysis and a debug build, not a running app.
  **Actually launching the app and walking through auth → Home → CBT → Videos → Books →
  Profile → offline → reconnect against the live backend (per the driving spec's §38-39) has
  not been done and should be a priority before shipping.**
- `.env` does not exist locally (only `.env.example`) — expected (gitignored, per-developer
  setup) but means the app cannot actually run/connect to a backend in this environment even
  if a device were available.
