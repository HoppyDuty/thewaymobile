import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../storage/secure_storage_service.dart';

part 'device_headers.g.dart';

/// The `X-Device-*` / `X-App-Version*` headers required on every API
/// request (see `phase_1_api_doc.md`). The fingerprint is generated once
/// per install and persisted in secure storage — it must stay stable
/// across app restarts since the backend uses it to enforce single-device
/// login and the 30-day new-device cooldown.
class DeviceHeaders {
  DeviceHeaders(this._secureStorage);

  final SecureStorageService _secureStorage;

  String? _fcmToken;

  /// Called once push notifications are wired up; included on subsequent requests.
  void setFcmToken(String? token) => _fcmToken = token;

  Future<Map<String, String>> build() async {
    final fingerprint = await _fingerprint();
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    String deviceName = 'Unknown device';
    String deviceOs = Platform.operatingSystem;
    String deviceType = Platform.isIOS ? 'ios' : 'android';

    if (Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceName = '${android.manufacturer} ${android.model}'.trim();
      deviceOs = 'Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceName = ios.name;
      deviceOs = '${ios.systemName} ${ios.systemVersion}';
    }

    return {
      'X-Device-Fingerprint': fingerprint,
      'X-Device-Type': deviceType,
      'X-Device-Name': deviceName,
      'X-Device-OS': deviceOs,
      'X-App-Version': packageInfo.version,
      'X-App-Version-Code': packageInfo.buildNumber,
      if (_fcmToken != null) 'X-FCM-Token': _fcmToken!,
    };
  }

  Future<String> _fingerprint() async {
    final existing = await _secureStorage.readDeviceFingerprint();
    if (existing != null) return existing;

    // Seed with a random UUID rather than a hardware identifier — those
    // (Android ID, IDFV) can change on reinstall/OS updates, which would
    // silently break single-device-login enforcement. A persisted random
    // seed, hashed once, is the stable identifier the backend actually needs.
    final seed = const Uuid().v4();
    final fingerprint = sha256.convert(utf8.encode(seed)).toString();
    await _secureStorage.writeDeviceFingerprint(fingerprint);
    return fingerprint;
  }
}

@Riverpod(keepAlive: true)
DeviceHeaders deviceHeaders(DeviceHeadersRef ref) {
  return DeviceHeaders(ref.watch(secureStorageServiceProvider));
}
