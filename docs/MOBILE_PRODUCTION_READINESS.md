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
3. **CBT** — visual rebuild of exam-type/mode/subject/topic selection, the exam-taking screen
   itself (highest-stakes UX in the app), results/review/bookmarks.
4. **Videos** — listing/detail/player/downloads visual rebuild.
5. **Books** — listing/detail/reader/saved visual rebuild.
6. **Profile** — hub + edit/stats/purchases/payments/preferences visual rebuild.
7. **Onboarding** — verify Rive assets actually exist and render (research flagged
   `assets/rive/` contains only a `.gitkeep`, no real `.riv` files — the onboarding screen may
   currently be silently falling back to a plain icon).
8. **Icon migration** — move the remaining ~150 `Icons.*` call sites onto `AppIcons`,
   expanding the mapping as needed per screen.
9. **Offline-architecture work** described in `UI_UX_RULES.md` §11: app-wide reconnect
   listening (not gated behind visiting the CBT tab), stale-while-revalidate caching for
   Home/Videos/Books/News, a basic cache for Profile.
10. **Centralize route names** — most feature routes are inline path-string literals; only
    pre-auth/gate routes are named `AppRoute` constants today.
11. **Backend yt-dlp / video-processing pipeline audit** — out of mobile's direct scope; see
    `thewaybackend/PRODUCTION_READINESS.md` for the backend-side follow-up needed.
12. **CRITICAL: fix the `rive_native` Android build blocker** — still open. ~~(a) bump to a
    newer `rive_native`/`rive` release~~ — **tried, did not work**: 0.1.11 (latest available)
    has the identical unfixed `Expand-Archive` call. Remaining options: (b) if `assets/rive/`
    genuinely has no `.riv` files in use yet (confirmed empty except `.gitkeep`), remove
    `rive`/`rive_native` until onboarding actually ships real Rive content, re-adding it then;
    (c) build from a machine/CI path with no space in it; (d) fork/patch `rive_native` (its
    setup script is open source) and point at the fork via a `dependency_override` — more
    durable than hand-patching `pub-cache` but real maintenance overhead. Needs a decision.

## Known limitations of this audit pass

- No Android emulator, iOS simulator, or physical device was available in this environment —
  everything above was verified via static analysis and a debug build, not a running app.
  **Actually launching the app and walking through auth → Home → CBT → Videos → Books →
  Profile → offline → reconnect against the live backend (per the driving spec's §38-39) has
  not been done and should be a priority before shipping.**
- `.env` does not exist locally (only `.env.example`) — expected (gitignored, per-developer
  setup) but means the app cannot actually run/connect to a backend in this environment even
  if a device were available.
