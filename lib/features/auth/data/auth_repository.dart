import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_setup.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'auth_api.dart';
import 'models/auth_session.dart';
import 'models/otp_challenge.dart';
import 'models/user_model.dart';

part 'auth_repository.g.dart';

const _cachedUserKey = 'cached_user';

/// Orchestrates [AuthApi] with local persistence: the JWT goes into secure
/// storage, the profile is cached in Hive so it's available offline (per
/// `app_flow.md`: "save the user's data ... I want the app to be fully
/// functional offline").
class AuthRepository {
  AuthRepository(this._api, this._secureStorage);

  final AuthApi _api;
  final SecureStorageService _secureStorage;

  UserModel? get cachedUser {
    final json = HiveSetup.authBox.get(_cachedUserKey);
    if (json == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<void> _persistSession(AuthSession session) async {
    await _secureStorage.writeAccessToken(session.accessToken);
    await HiveSetup.authBox.put(_cachedUserKey, session.user.toJson());
  }

  Future<OtpChallenge> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? referralCode,
  }) {
    return _api.register(
      firstName: firstName,
      lastName: lastName,
      username: username,
      email: email,
      phone: phone,
      password: password,
      passwordConfirmation: passwordConfirmation,
      referralCode: referralCode,
    );
  }

  Future<UserModel> verifyRegistration({required String otpToken, required String code}) async {
    final session = await _api.verifyRegistration(otpToken: otpToken, code: code);
    await _persistSession(session);
    return session.user;
  }

  Future<OtpChallenge> login({required String identifier, required String password}) {
    return _api.login(identifier: identifier, password: password);
  }

  Future<UserModel> verifyLogin({required String otpToken, required String code}) async {
    final session = await _api.verifyLogin(otpToken: otpToken, code: code);
    await _persistSession(session);
    return session.user;
  }

  Future<OtpChallenge> resendOtp({required String otpToken, required String type}) {
    return _api.resendOtp(otpToken: otpToken, type: type);
  }

  Future<UserModel> googleSignIn({required String idToken}) async {
    final session = await _api.googleCallback(idToken: idToken);
    await _persistSession(session);
    return session.user;
  }

  Future<UserModel?> refreshProfile() async {
    final user = await _api.me();
    await HiveSetup.authBox.put(_cachedUserKey, user.toJson());
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {
      // Best-effort — clear the local session regardless of whether the
      // server call succeeds (e.g. no network).
    }
    await _secureStorage.clearSession();
    await HiveSetup.authBox.delete(_cachedUserKey);
  }

  Future<OtpChallenge?> forgotPassword({required String email}) => _api.forgotPassword(email: email);

  Future<String> forgotPasswordVerify({required String otpToken, required String code}) =>
      _api.forgotPasswordVerify(otpToken: otpToken, code: code);

  Future<void> forgotPasswordReset({
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) =>
      _api.forgotPasswordReset(
        resetToken: resetToken,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  Future<bool> hasStoredSession() async {
    final token = await _secureStorage.readAccessToken();
    return token != null;
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(authApiProvider), ref.watch(secureStorageServiceProvider));
}
