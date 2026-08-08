import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Content-shaped skeleton for the Home dashboard's first load
/// (`uiuxrules.md` §5 — never a blank screen or generic spinner here).
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              const ShimmerBox(width: 48, height: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: ShimmerBox(height: 18)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerBox(height: 160, borderRadius: BorderRadius.all(Radius.circular(18))),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              5,
              (_) => const ShimmerBox(width: 56, height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const ShimmerListTile(),
          const ShimmerListTile(),
          const ShimmerListTile(),
        ],
      ),
    );
  }
}
