import '../../data/models/user_model.dart';

/// App-wide "is the user logged in" state. Deliberately separate from the
/// transient loading/error state of any one screen's submit button — this
/// is what the router reads to decide whether to show auth screens or the
/// authenticated app shell.
sealed class AuthSessionState {
  const AuthSessionState();
}

/// Still checking secure storage / refreshing the cached profile — the
/// splash screen stays up during this state.
class AuthSessionUnknown extends AuthSessionState {
  const AuthSessionUnknown();
}

class AuthSessionUnauthenticated extends AuthSessionState {
  const AuthSessionUnauthenticated();
}

class AuthSessionAuthenticated extends AuthSessionState {
  const AuthSessionAuthenticated(this.user);
  final UserModel user;
}
