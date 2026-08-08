import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_radius.dart';

/// Shimmer skeleton loading — per `uiuxrules.md` §5: initial page/list
/// loads must show content-shaped placeholders, never a blank screen or a
/// generic full-screen spinner.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
      child: child,
    );
  }
}

/// A single shimmering block — the building unit for skeleton layouts
/// (text lines, thumbnails, avatars, cards).
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius ?? AppRadius.smRadius,
      ),
    );
  }
}

/// Skeleton for a horizontal list card (news preview, course card, etc.).
class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 72, height: 72, borderRadius: BorderRadius.all(Radius.circular(12))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 14),
                const SizedBox(height: 8),
                ShimmerBox(width: MediaQuery.sizeOf(context).width * 0.4, height: 14),
                const SizedBox(height: 8),
                ShimmerBox(width: MediaQuery.sizeOf(context).width * 0.25, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
