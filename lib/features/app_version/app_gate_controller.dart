import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_gate_state.dart';
import 'app_version_api.dart';

part 'app_gate_controller.g.dart';

@Riverpod(keepAlive: true)
class AppGateController extends _$AppGateController {
  @override
  AppGateState build() {
    _check();
    return const AppGateChecking();
  }

  Future<void> _check() async {
    try {
      final result = await ref.read(appVersionApiProvider).check();
      state = result.isBlocking ? AppGateBlocked(result) : AppGateClear(result.hasOptionalUpdate ? result : null);
    } catch (_) {
      // Never let a version-check failure lock users out of an
      // offline-first app — fail open.
      state = const AppGateCheckFailed();
    }
  }

  Future<void> recheck() async {
    state = const AppGateChecking();
    await _check();
  }
}
