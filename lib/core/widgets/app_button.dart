import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The one button every primary CTA in the app should use, so loading
/// state, disabled state, and styling stay consistent everywhere
/// (`UI_UX_RULES.md` §6/§15 — short actions get an iOS-style indicator,
/// not a Material spinner, and every screen shares one button component).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? CupertinoActivityIndicator(color: Theme.of(context).colorScheme.onPrimary)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );
  }
}
