import 'app_version_check.dart';

/// Gates entry into the rest of the app on startup, per `uiuxrules.md` §25's
/// startup sequence (splash → init → version check → auth check → home).
/// The router's redirect logic checks this *before* auth state — a blocked
/// version check wins regardless of whether the user is logged in.
sealed class AppGateState {
  const AppGateState();
}

class AppGateChecking extends AppGateState {
  const AppGateChecking();
}

/// Version check failed (offline, server down, etc.) — fail open rather
/// than locking users out of an offline-first app over a version check.
class AppGateCheckFailed extends AppGateState {
  const AppGateCheckFailed();
}

class AppGateBlocked extends AppGateState {
  const AppGateBlocked(this.check);
  final AppVersionCheck check;
}

class AppGateClear extends AppGateState {
  const AppGateClear(this.optionalUpdate);
  final AppVersionCheck? optionalUpdate;
}
