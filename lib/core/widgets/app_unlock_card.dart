import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// The paywall/unlock prompt shown on premium CBT exam types, video
/// courses, and books — previously three near-identical, independently
/// styled copies using a generic `tertiaryContainer`. Unifies them and
/// applies the brand gold accent: unlocking premium content is exactly the
/// kind of restrained "premium moment" `UI_UX_RULES.md` §2 reserves gold
/// for, not decoration.
class AppUnlockCard extends StatelessWidget {
  const AppUnlockCard({super.key, required this.title, this.subtitle, required this.onTap});

  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppColors.gold50,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius, side: BorderSide(color: AppColors.gold200)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
          leading: const CircleAvatar(
            backgroundColor: AppColors.gold200,
            foregroundColor: AppColors.gold900,
            child: Icon(AppIcons.unlock, size: 20),
          ),
          title: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: AppColors.gold900)),
          subtitle: subtitle != null
              ? Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.gold800))
              : null,
          trailing: const Icon(AppIcons.chevronRight, color: AppColors.gold800),
          onTap: onTap,
        ),
      ),
    );
  }
}
