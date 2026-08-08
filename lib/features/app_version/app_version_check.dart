import 'dart:io';

/// Mirrors the response of `POST /app/version` (see `AppVersionService::check()`
/// on the backend — `maintenance` is checked first; if not under
/// maintenance, `status`/`force_update`/`update_url` describe the version
/// comparison).
class AppVersionCheck {
  const AppVersionCheck({
    required this.maintenance,
    required this.message,
    this.maintenanceTitle,
    this.maintenanceEndsAt,
    this.status,
    this.forceUpdate = false,
    this.updateUrl,
    this.latestVersion,
  });

  final bool maintenance;
  final String message;
  final String? maintenanceTitle;
  final DateTime? maintenanceEndsAt;

  /// `force_update` | `optional_update` | `up_to_date` — null while under maintenance.
  final String? status;
  final bool forceUpdate;
  final String? updateUrl;
  final String? latestVersion;

  bool get isBlocking => maintenance || forceUpdate;
  bool get hasOptionalUpdate => !maintenance && status == 'optional_update';

  factory AppVersionCheck.fromJson(Map<String, dynamic> json) {
    return AppVersionCheck(
      maintenance: json['maintenance'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      maintenanceTitle: json['title'] as String?,
      maintenanceEndsAt: json['ends_at'] != null ? DateTime.tryParse(json['ends_at'] as String) : null,
      status: json['status'] as String?,
      forceUpdate: json['force_update'] as bool? ?? false,
      updateUrl: json['update_url'] as String?,
      latestVersion: json['latest_version'] as String?,
    );
  }
}

String currentPlatformName() => Platform.isIOS ? 'ios' : 'android';
