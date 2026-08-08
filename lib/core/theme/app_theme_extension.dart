import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Semantic colors that don't map cleanly onto Material 3's [ColorScheme]
/// (success/warning/info) so screens never hardcode a [Color] directly —
/// every color used in the app should come from either `Theme.of(context).colorScheme`
/// or `Theme.of(context).extension<AppThemeExtension>()`.
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.onSuccess,
    required this.onWarning,
    required this.onDanger,
    required this.onInfo,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color onSuccess;
  final Color onWarning;
  final Color onDanger;
  final Color onInfo;

  static const light = AppThemeExtension(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
    info: AppColors.info,
    onSuccess: Colors.white,
    onWarning: Colors.white,
    onDanger: Colors.white,
    onInfo: Colors.white,
  );

  static const dark = AppThemeExtension(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFA726),
    danger: Color(0xFFEF5350),
    info: Color(0xFF4FC3F7),
    onSuccess: Colors.black,
    onWarning: Colors.black,
    onDanger: Colors.black,
    onInfo: Colors.black,
  );

  @override
  AppThemeExtension copyWith({
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
    Color? onSuccess,
    Color? onWarning,
    Color? onDanger,
    Color? onInfo,
  }) {
    return AppThemeExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
      onSuccess: onSuccess ?? this.onSuccess,
      onWarning: onWarning ?? this.onWarning,
      onDanger: onDanger ?? this.onDanger,
      onInfo: onInfo ?? this.onInfo,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
    );
  }
}

/// Convenience accessor: `context.appColors.success`.
extension AppThemeExtensionX on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>() ?? AppThemeExtension.light;
}
