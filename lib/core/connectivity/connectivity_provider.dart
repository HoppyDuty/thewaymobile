import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Global connectivity stream — the single source of truth for
/// online/offline state (`uiuxrules.md` §29: "do not make every screen
/// independently implement connectivity logic; use centralized
/// infrastructure with granular UI consumption"). `phase4.md`'s CBT/sync
/// spec names this exact provider; every feature (not just CBT) should
/// consume it rather than talking to `connectivity_plus` directly.
@Riverpod(keepAlive: true)
Stream<bool> connectivity(ConnectivityRef ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none))
      .distinct();
}
