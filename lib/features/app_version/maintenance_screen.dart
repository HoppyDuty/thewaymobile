import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_logo.dart';
import 'app_gate_controller.dart';

class MaintenanceScreen extends ConsumerWidget {
  const MaintenanceScreen({super.key, required this.title, required this.message, this.endsAt});

  final String? title;
  final String message;
  final DateTime? endsAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                Icon(AppIcons.maintenance, size: 56, color: theme.colorScheme.primary),
                const SizedBox(height: AppSpacing.md),
                Text(title ?? "We'll be right back", style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                if (endsAt != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Expected back: ${DateFormat.yMMMd().add_jm().format(endsAt!)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Try Again',
                  onPressed: () => ref.read(appGateControllerProvider.notifier).recheck(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
