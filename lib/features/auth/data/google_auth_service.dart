import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/env/env.dart';

part 'google_auth_service.g.dart';

/// Wraps `google_sign_in`'s singleton `GoogleSignIn.instance`, which
/// requires `initialize()` to be awaited exactly once before any other
/// method is called — this service is that one call site.
class GoogleAuthService {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: Env.googleServerClientId.isEmpty ? null : Env.googleServerClientId,
    );
    _initialized = true;
  }

  /// Returns a Google ID token the backend can verify, or throws if the
  /// user cancels or Google doesn't return one.
  Future<String> signInAndGetIdToken() async {
    await _ensureInitialized();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google sign-in did not return an ID token.');
    }
    return idToken;
  }
}

@Riverpod(keepAlive: true)
GoogleAuthService googleAuthService(GoogleAuthServiceRef ref) => GoogleAuthService();
