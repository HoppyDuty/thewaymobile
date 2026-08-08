import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

/// Wraps [FlutterSecureStorage] for the handful of values that must never
/// live in Hive/SharedPreferences: the JWT access token and the device
/// fingerprint seed (single-device-login enforcement depends on the
/// fingerprint being stable across app restarts, so it's generated once
/// and persisted here rather than recomputed every launch).
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _deviceFingerprintKey = 'device_fingerprint';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> writeAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> deleteAccessToken() => _storage.delete(key: _accessTokenKey);

  Future<String?> readDeviceFingerprint() =>
      _storage.read(key: _deviceFingerprintKey);

  Future<void> writeDeviceFingerprint(String fingerprint) =>
      _storage.write(key: _deviceFingerprintKey, value: fingerprint);

  /// Clears everything except the device fingerprint — that must survive
  /// logout so the 30-day new-device cooldown logic keeps working.
  Future<void> clearSession() => deleteAccessToken();
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorageService(SecureStorageServiceRef ref) {
  return SecureStorageService(const FlutterSecureStorage());
}
