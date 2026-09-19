# The Way Mobile — Ground-Up Rebuild Guide & Plan

## 0. What this document is, and why it exists

The work recorded in `MOBILE_PRODUCTION_READINESS.md` (Milestones 1–11) was **not** a
ground-up visual rebuild, even though it touched nearly every screen. It was: build a design
token foundation (colors, icons, a floating nav bar, a real splash), then sweep the existing
screens onto that foundation (icon migration, loading-indicator consistency, a few deliberate
gold accents) while fixing specific, evidence-based bugs found along the way (missing delete
confirmations, a mislabeled Google icon, a PDF reader that leaked a raw exception, a video
player with no error handling, missing accessibility labels). The underlying **layout,
composition, and visual hierarchy of almost every individual screen is unchanged** from before
that work started.

That's a legitimate, valuable pass — the app is measurably more consistent and has fewer real
bugs than it did. But it is not what "ground-up rebuild" means, and conflating the two would be
dishonest about where the app actually stands. This document is the plan for the part that
hasn't happened yet: actually re-composing each screen's layout, hierarchy, and interaction
design to the Apple-quality bar the driving spec asks for, not just re-skinning it with new
tokens.

**Read `UI_UX_RULES.md` first.** It's the permanent design-system reference (colors, type
scale, spacing, icon policy, loading-state levels, offline/error/empty-state rules, component
architecture). This document does not repeat that content — it's the *plan* for applying it at
the layout level, screen by screen, in order.

---

## 1. What "rebuilt" concretely means (the bar every screen must clear)

A screen is not "rebuilt" because it uses `AppIcons` and the right spacing tokens — that's the
baseline every screen already has. A screen is rebuilt when someone can look at it and answer
all of these without hesitation:

1. **What's the one most important thing here?** — is there a clear primary focal point, or does
   everything compete for attention equally? (Miller's Law / information hierarchy, backend
   `uiuxrules.md` §3.)
2. **Does the layout use intentional rhythm**, not just correct spacing tokens? Sections should
   feel composed — varied card treatments, deliberate use of whitespace to group related content,
   not a uniform stack of same-shaped cards with `AppSpacing.md` between all of them.
3. **Is there a moment of restraint-broken-on-purpose?** — one deliberate visual accent per
   screen (the gold treatments already applied are examples: leaderboard rank, unlock card,
   streak) rather than either flat uniformity everywhere or accents scattered without meaning.
4. **Does motion tell you what happened?** — a state change (an answer selected, a download
   starting, a purchase confirmed) should have a visible, brief, purposeful transition, not just
   an instant repaint.
5. **Would removing one arbitrary card/section break the reading order?** — if sections are
   interchangeable in position, the hierarchy isn't real yet.

If a screen already clears this bar as-is (verified by actually looking at it, not assumed),
leave it alone — rebuilding something that's already good is waste, and the spec is explicit
about not doing that.

---

## 2. Hard prerequisite: get a device or emulator into the loop

Every fix made in Milestones 1–11 was safe to make *blind* (verified by `flutter analyze` +
reading the code) because none of it changed layout — token/icon swaps, loading-indicator
types, and added dialogs are all things you can reason about correctness for without seeing
them render. **Layout and composition work is not that kind of change.** Spacing rhythm,
visual hierarchy, motion timing, and "does this feel premium" are fundamentally things that
have to be looked at, not deduced from source code.

This environment had no Android emulator, iOS simulator, or physical device available for the
entire Milestones 1–11 pass — an explicit, repeated limitation in `MOBILE_PRODUCTION_READINESS.md`.
**Before Phase 1 of this plan starts, that has to change.** Options, in order of preference:
1. Run this plan from a machine/session with a connected physical device or a working
   emulator/simulator.
2. If working blind is unavoidable for a stretch, restrict changes to things verifiable by
   `flutter analyze` + widget tests, and explicitly flag every layout change as "NOT VISUALLY
   VERIFIED" rather than implying it was checked.

Do not skip this and proceed as if static analysis is equivalent to a design review. It isn't.

---

## 3. Current state by screen group (from direct code audit — not assumed)

Confidence key: **SOLID** = read directly, functionally and structurally sound, rebuild is
about layout/hierarchy polish only. **WEAK** = read directly, has real structural/functional
gaps beyond visual polish. **UNREVIEWED** = not directly read by any milestone yet.

| Group | Screens | State | Notes |
|---|---|---|---|
| Splash/Onboarding | Splash, Onboarding | **SOLID** (rebuilt in M1/M3) | Already has real motion, real logo, real app icon. Onboarding is icon-only now (Rive removed) — could get illustration treatment later (Lottie is still a dependency) but isn't broken. |
| Auth | Login, Register, OTP Verify, Forgot/Reset Password | **SOLID** structurally, **generic** visually | Correct validation, loading states, error handling, duplicate-submit guards (M2). Layout is a plain centered-column form on every screen — functional, not distinctive. This is the highest-visibility, lowest-complexity place to start (see Phase 1). |
| Home | Home + 6 section widgets | **SOLID**, partially polished | Carousel/leaderboard got real treatment (M3/M8: scrim, gold accent, SWR caching). Continue-learning, recommended-courses, news-preview, quick-actions are still plain horizontal card rows — functional, generic. |
| CBT | Exam types, mode/subject/topic selection, session setup, exam screen, result, review, bookmarks | **SOLID** structurally | This is the most functionally sophisticated flow in the app (offline delta sync, autosave, question navigator, gold celebration on the result screen, timer urgency, accessibility labels — M4/M9). Selection-flow screens (mode/subject/topic/setup) are plain list/card layouts. The exam screen itself is functionally excellent; visual composition is fine but not distinctive. |
| Videos | Courses list, detail, player, downloads, local player | **SOLID** | Listing/detail already had shimmer, chips, correct progress states before this pass (M5/M6/M10/M11 layered fixes on top, not a rebuild). |
| Books | List, detail, reader, my-saved | **SOLID** | Same finding as Videos. PDF reader now has correct loading/error states (M11) but its own UI (just an AppBar + PDFView) has no reading-experience polish (page indicator, brightness, bookmarks). |
| Profile | Hub, edit, stats, purchases, payment history, preferences, delete account | **SOLID**, generic | Icon-migrated, gold streak accent (M7). Stats screen in particular is a plain list of icon+value rows — a natural rebuild candidate (see Phase 5). |
| Notifications | List | **SOLID** | SWR-cached (M8), icon-migrated. Plain list, low complexity, low priority. |
| News | List, detail (with comments) | **SOLID** | Icon-migrated. Not deeply reviewed beyond that. |
| Shepherd (AI tutor) | Home, chat, weak areas, study plan | **SOLID** | Icon-migrated, destructive-delete confirmation added (M10). Chat UI specifically — bubble layout, typing/streaming states — **not reviewed**, worth a dedicated look given it's a differentiated feature (see Phase 6). |
| Payments | Gateway sheet, webview | **SOLID** | Icon-migrated only. Low priority — it's a means to an end (checkout), not a destination screen. |
| Dictionary | Search screen | **SOLID** | Icon-migrated only, otherwise unreviewed beyond that. |

**Full 48-screen inventory** (routes, triggers, one-line purpose) was produced during this
session's research but not persisted as a doc artifact — regenerate it if a complete route map
is needed (it's a ~20-minute Explore-agent task, not worth maintaining by hand as a static file
that will drift).

---

## 4. Phased plan

Ordered by: user-visible impact × how low-risk it is to verify (once a device is available).
Each phase is its own milestone — implement, look at it on a real device, commit, move on. Do
not batch multiple phases into one commit.

### Phase 0 — Device/emulator access (blocking, see §2)

### Phase 1 — Auth (Login, Register, OTP Verify, Forgot/Reset Password)
**Why first:** every user sees this before anything else; it's structurally simple (no offline
state, no complex data), so it's the lowest-risk place to establish the actual visual language
in practice rather than in the abstract. Also the biggest gap between "functionally correct"
and "looks premium" — currently a plain centered form on white.

**Direction:**
- Give the logo/headline area real presence instead of a small centered logo + generic
  headline — this is the first-impression screen, it should not look identical to every other
  form screen in the app.
- OTP entry (`OtpInput`) is already a well-built segmented input — the surrounding screen
  (progress-through-flow indication: "Step 1 of 2," a sense of where the user is in
  register→OTP→home) could use more presence.
- The Google sign-in button and the "or" divider are currently styled with default
  `OutlinedButton`/`Divider` — this is fine functionally but is exactly the kind of "generic
  Flutter" moment the spec calls out.
- Do not touch the validation logic, error handling, or duplicate-submit guards — those are
  correct (M2) and out of scope for this phase.

### Phase 2 — Home (section widgets: continue-learning, recommended-courses, news-preview, quick-actions)
**Why second:** highest-traffic screen in the app; carousel and leaderboard already show what
"done" looks like (M3/M8) — this phase is bringing the other four sections up to that same bar,
not inventing a new language.

**Direction:**
- `QuickActionsSection` is 5 identical icon-in-square tiles in a row — consider whether all 5
  actions deserve equal visual weight, or whether 1-2 (the ones product data would say are most
  used — Topical Study and My Videos are guesses, confirm with actual usage if available) should
  be more prominent.
- `ContinueLearningSection`/`RecommendedCoursesSection` are near-identical horizontal card
  rows — differentiate them (continue-learning is "pick up where you left off," recommended is
  "discover something new" — the layouts currently don't communicate that difference).
- `NewsPreviewSection` reuses `NewsCard` directly, full-width, stacked — consider whether news
  belongs in this dense a treatment on the primary dashboard, or should be more compact here
  with full treatment reserved for the News tab itself.

### Phase 3 — CBT selection flow (mode/subject/topic selection, session setup)
**Why third, not first despite being "highest-stakes":** the exam-taking screen itself
(`exam_screen.dart`) is already functionally excellent and was just polished (M9) — rebuilding
its layout is higher-risk (breaking autosave/offline behavior by restructuring the widget tree)
for comparatively less payoff than the selection screens leading into it, which are plain list/
card layouts with real room for hierarchy improvement and zero state-management risk.

**Direction:**
- These four screens (mode → subject → topic → setup) are sequential steps in one flow but
  currently don't visually communicate progression (no step indicator, no visual continuity
  between them beyond shared tokens).
- `AppUnlockCard` (M6) already gives the paywall moment real presence — the free/paid mode
  cards around it are plain `Card`+`ListTile` — give the mode choice itself (practice vs. exam
  vs. topical, etc.) more visual distinction per mode, not identical rows.
- If the exam screen itself gets touched in a later phase, treat it as its own,
  carefully-scoped, device-tested milestone — not bundled with this one.

### Phase 4 — Videos & Books (listing/detail; reader UI)
**Direction:**
- Listing/detail screens: differentiate the "free preview" vs "owned" vs "locked" visual states
  more — right now access state is mostly communicated via the unlock card's presence/absence,
  which is correct but minimal.
- PDF reader (`pdf_reader_screen.dart`): currently just an `AppBar` + `PDFView`, no in-reader
  chrome (page X of Y, a way to jump to a page, brightness/theme control some reader apps
  offer). Scope this modestly — a page indicator and jump-to-page is plausibly worth it: a
  premium 200-page textbook with zero reading chrome doesn't feel finished.
- Video player: the description/title area below the player is a plain `Column` of text —
  low-value to rebuild given the player itself is the point of the screen; deprioritize.

### Phase 5 — Profile
**Direction:**
- `StatsScreen` (11 stat rows in a plain list per the audit) is the clearest rebuild candidate
  in Profile — a stats screen with 11 equally-weighted rows is a Miller's-Law violation
  (`UI_UX_RULES.md` philosophy) waiting to happen. Group related stats (exam performance vs.
  content consumption vs. streaks) rather than one flat list.
- Hub screen (`profile_screen.dart`) already has the stats-row gold-accent treatment (M7) and a
  clean menu section — lower priority than Stats itself.

### Phase 6 — Shepherd (AI tutor) chat UI
**Why included despite lower usage than Home/CBT:** it's a differentiated, AI-forward feature
that's explicitly named in the driving spec as a product differentiator, and its chat/bubble
UI has not been reviewed at all by any milestone so far — unknown whether it needs work,
which itself is worth resolving.
**Direction:** review `chat_screen.dart` first (currently unreviewed) before assuming any
specific direction — this phase starts with an audit, not a prescribed redesign.

### Phase 7 (lower priority, do opportunistically) — Notifications, News, Payments, Dictionary
Lower-traffic, structurally simple screens. Bring them to the same bar as everything else once
the above phases establish what that bar looks like in practice, rather than guessing at a
design language for them first.

---

## 5. Process for each phase

1. **Look at the current screen on a device before touching code.** Not "read the widget tree
   and imagine it" — actually run the app and look.
2. **Write down, in one paragraph, what's wrong with it** against the §1 bar. If nothing's
   wrong, skip the phase — don't rebuild for its own sake.
3. **Implement.**
4. **Look at it again on the device.** Compare against the paragraph from step 2 — did it
   actually fix what was identified?
5. **Run `flutter analyze` clean, then `flutter test` if relevant tests exist.**
6. **Commit** with a message that states what changed and, honestly, what was and wasn't
   visually verified — matching the pattern already established in the last 11 commits.
7. **Update `MOBILE_PRODUCTION_READINESS.md`** with the milestone, same as before.

Do not batch two phases into one commit, and do not mark something "VERIFIED" for visual
appearance unless it was actually looked at on a device — that distinction has been kept
honest for 11 milestones running and matters more here than anywhere else in this project.

---

## 6. Explicit non-goals for this plan

- **Not** touching CBT's offline-sync engine, exam-session persistence, or scoring logic — those
  are correct and out of scope; this plan is presentation-layer only.
- **Not** re-architecting state management, navigation, or the API layer — all confirmed solid
  in the Milestone 1 audit.
- **Not** a mandate to add animation/motion/glassmorphism everywhere — per `UI_UX_RULES.md`,
  restraint is part of the bar, not a checklist to exhaust.
- **Not** a mandate to touch every one of the 48 screens — several (§3, "SOLID" with no notes)
  may not need layout work at all; confirm on a device before assuming otherwise.
