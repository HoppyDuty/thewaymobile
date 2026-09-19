import 'package:flutter/cupertino.dart';

/// Single source of truth for the app's icon glyphs (`UI_UX_RULES.md` §4).
///
/// Screens reference `AppIcons.home` etc. rather than `CupertinoIcons.*`/
/// `Icons.*` directly, so swapping the underlying icon set later (e.g. to a
/// licensed SF-Symbols-style pack or a custom SVG set) is a one-file change
/// instead of a find/replace across every screen. Cupertino icons are used
/// as the initial glyph source — already a zero-cost dependency, genuinely
/// Apple-styled, and consistent in stroke weight — until/unless the product
/// picks a dedicated icon library.
///
/// Each destination that appears in a togglable context (tab bar, bookmark
/// toggle, etc.) gets both an outlined and a filled variant; content that's
/// never "selected" gets a single glyph.
abstract final class AppIcons {
  // ─── Bottom navigation ──────────────────────────────────────────────────
  static const IconData home = CupertinoIcons.house;
  static const IconData homeSelected = CupertinoIcons.house_fill;
  static const IconData cbt = CupertinoIcons.doc_text;
  static const IconData cbtSelected = CupertinoIcons.doc_text_fill;
  static const IconData video = CupertinoIcons.play_rectangle;
  static const IconData videoSelected = CupertinoIcons.play_rectangle_fill;
  static const IconData book = CupertinoIcons.book;
  static const IconData bookSelected = CupertinoIcons.book_fill;
  static const IconData profile = CupertinoIcons.person;
  static const IconData profileSelected = CupertinoIcons.person_fill;

  // ─── Quick actions / content ────────────────────────────────────────────
  static const IconData topic = CupertinoIcons.square_grid_2x2;
  static const IconData dictionary = CupertinoIcons.textformat_abc;
  static const IconData library = CupertinoIcons.collections;
  static const IconData bookmark = CupertinoIcons.bookmark;
  static const IconData bookmarkSelected = CupertinoIcons.bookmark_fill;
  static const IconData download = CupertinoIcons.arrow_down_circle;
  static const IconData downloadDone = CupertinoIcons.checkmark_circle_fill;

  // ─── Chrome / actions ───────────────────────────────────────────────────
  static const IconData search = CupertinoIcons.search;
  static const IconData settings = CupertinoIcons.gear;
  static const IconData notification = CupertinoIcons.bell;
  static const IconData notificationActive = CupertinoIcons.bell_fill;
  static const IconData back = CupertinoIcons.back;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData share = CupertinoIcons.share;
  static const IconData edit = CupertinoIcons.pencil;
  static const IconData logout = CupertinoIcons.square_arrow_right;
  static const IconData chevronRight = CupertinoIcons.chevron_right;
  static const IconData sparkles = CupertinoIcons.sparkles;

  // ─── Status ─────────────────────────────────────────────────────────────
  static const IconData offline = CupertinoIcons.wifi_slash;
  static const IconData success = CupertinoIcons.checkmark_circle;
  static const IconData warning = CupertinoIcons.exclamationmark_triangle;
  static const IconData error = CupertinoIcons.xmark_circle;
}
