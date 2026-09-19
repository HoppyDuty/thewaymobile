import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_logo.dart';

/// Blocking "Update Required" screen (`uiuxrules.md` §27). No dismiss —
/// the only action is opening the store listing.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key, required this.updateUrl, this.message});

  final String? updateUrl;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 80),
                const SizedBox(height: AppSpacing.xl),
                Icon(AppIcons.systemUpdate, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text('Update Required', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message ?? 'This version is no longer supported. Please update to continue.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Update Now',
                  onPressed: updateUrl == null
                      ? null
                      : () => launchUrl(Uri.parse(updateUrl!), mode: LaunchMode.externalApplication),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
