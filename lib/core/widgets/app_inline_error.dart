import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Inline form-level error — icon + message on a subtle tinted background,
/// for a validation/submit failure that should stay in context on the
/// current form (as opposed to [AppErrorState], which replaces the whole
/// screen when there's nothing else useful to show). Never relies on color
/// alone (`UI_UX_RULES.md` §14) — always paired with an icon and text.
class AppInlineError extends StatelessWidget {
  const AppInlineError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: TextStyle(color: colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
