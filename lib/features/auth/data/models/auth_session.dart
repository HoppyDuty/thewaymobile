import 'user_model.dart';

/// Result of a successful `/auth/*/verify` or `/auth/google/callback` call.
class AuthSession {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final UserModel user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: json['access_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
