/// Centralized spacing scale — never hardcode a raw `EdgeInsets.all(13)`
/// or similar in a screen; use one of these instead (per `uiuxrules.md` §32).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
