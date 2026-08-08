import 'package:flutter/material.dart';

/// Consistent "Section Title  ...  View All" header used across Home,
/// News, and anywhere else a horizontally-scrolling or truncated section
/// links to its own full list screen.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({super.key, required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        if (onViewAll != null)
          TextButton(onPressed: onViewAll, child: const Text('View All')),
      ],
    );
  }
}
