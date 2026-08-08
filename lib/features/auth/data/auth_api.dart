import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import 'models/auth_session.dart';
import 'models/otp_challenge.dart';
import 'models/user_model.dart';

part 'auth_api.g.dart';

/// Raw calls to the `/auth/*` endpoints documented in `phase_1_api_doc.md`.
/// No business logic here — that lives in `AuthRepository`/`AuthController`.
class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<OtpChallenge> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) async {
    final data = await _client.post('/auth/register', data: {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      if (referralCode != null && referralCode.isNotEmpty) 'referral_code': referralCode,
    });
    return OtpChallenge.fromJson(data!);
  }

  Future<AuthSession> verifyRegistration({required String otpToken, required String code}) async {
    final data = await _client.post('/auth/register/verify', data: {
      'otp_token': otpToken,
      'code': code,
    });
    return AuthSession.fromJson(data!);
  }

  Future<OtpChallenge> login({required String identifier, required String password}) async {
    final data = await _client.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    return OtpChallenge.fromJson(data!);
  }

  Future<AuthSession> verifyLogin({required String otpToken, required String code}) async {
    final data = await _client.post('/auth/login/verify', data: {
      'otp_token': otpToken,
      'code': code,
    });
    return AuthSession.fromJson(data!);
  }

  Future<OtpChallenge> resendOtp({required String otpToken, required String type}) async {
    final data = await _client.post('/auth/otp/resend', data: {
      'otp_token': otpToken,
      'type': type,
    });
    return OtpChallenge.fromJson(data!);
  }

  Future<AuthSession> googleCallback({required String idToken}) async {
    final data = await _client.post('/auth/google/callback', data: {'id_token': idToken});
    return AuthSession.fromJson(data!);
  }

  Future<void> logout() => _client.post('/auth/logout');

  Future<UserModel> me() async {
    final data = await _client.get('/auth/me');
    return UserModel.fromJson(data!['user'] as Map<String, dynamic>? ?? data);
  }

  /// Returns `null` if no account matches [email] — the backend always
  /// reports success either way (anti-enumeration), but only issues a real
  /// `otp_token` for an email that actually has an account.
  Future<OtpChallenge?> forgotPassword({required String email}) async {
    final data = await _client.post('/auth/forgot-password', data: {'email': email});
    if (data == null || data['otp_token'] == null) return null;
    return OtpChallenge.fromJson(data);
  }

  Future<String> forgotPasswordVerify({required String otpToken, required String code}) async {
    final data = await _client.post('/auth/forgot-password/verify', data: {
      'otp_token': otpToken,
      'code': code,
    });
    return data!['reset_token'] as String;
  }

  Future<void> forgotPasswordReset({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) =>
      _client.post('/auth/forgot-password/reset', data: {
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
}

@Riverpod(keepAlive: true)
AuthApi authApi(AuthApiRef ref) => AuthApi(ref.watch(apiClientProvider));
