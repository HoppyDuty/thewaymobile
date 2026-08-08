import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_session_state.dart';

part 'auth_session_controller.g.dart';

/// Owns [AuthSessionState] for the whole app. `build()` returns
/// immediately with [AuthSessionUnknown] and kicks off an async bootstrap
/// (check secure storage → show the cached profile immediately if one
/// exists → best-effort refresh from `/auth/me`) so the router never has
/// to `await` anything to decide where to send the user.
@Riverpod(keepAlive: true)
class AuthSessionController extends _$AuthSessionController {
  @override
  AuthSessionState build() {
    _bootstrap();
    return const AuthSessionUnknown();
  }

  Future<void> _bootstrap() async {
    final repo = ref.read(authRepositoryProvider);
    final hasSession = await repo.hasStoredSession();

    if (!hasSession) {
      state = const AuthSessionUnauthenticated();
      return;
    }

    final cached = repo.cachedUser;
    if (cached != null) {
      state = AuthSessionAuthenticated(cached);
    }

    try {
      final fresh = await repo.refreshProfile();
      if (fresh != null) state = AuthSessionAuthenticated(fresh);
    } catch (_) {
      // Offline or the token is no longer valid. If we had nothing cached,
      // fall back to unauthenticated; if we did have a cached profile,
      // keep showing it — the app should still work offline.
      if (cached == null) state = const AuthSessionUnauthenticated();
    }
  }

  void setAuthenticated(UserModel user) {
    state = AuthSessionAuthenticated(user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthSessionUnauthenticated();
  }
}
