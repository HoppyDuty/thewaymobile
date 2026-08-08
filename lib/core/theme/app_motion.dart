import 'package:flutter/animation.dart';

/// Centralized animation timings/curves (`uiuxrules.md` §17/§32) — motion
/// should feel consistent across the whole app, not tuned per-screen.
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  /// How long the offline banner waits before appearing, so a brief
  /// connectivity blip doesn't flash it on/off (`uiuxrules.md` describes
  /// this exact 2-second debounce for the equivalent web behavior).
  static const offlineBannerDebounce = Duration(seconds: 2);
}

abstract final class AppCurves {
  static const standard = Curves.easeInOutCubic;
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
}
