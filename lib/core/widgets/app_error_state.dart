import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Full-screen "something went wrong" state — used when there's no cached
/// data to fall back on. If cached data exists, prefer showing it with an
/// [AppOfflineBanner]/inline error instead of replacing the whole screen
/// (`uiuxrules.md` §5/§7/§8 — never blow away useful content for an error).
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 160,
                child: AppButton(label: 'Try Again', onPressed: onRetry, icon: Icons.refresh_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
