import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import 'app_shimmer.dart';

/// Every remote image in the app should go through this: cached, a
/// shimmer placeholder while loading, and an icon fallback on failure
/// (`uiuxrules.md` §28 — never a raw broken-image icon or an infinite spinner).
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    if (url == null || url!.isEmpty) {
      return ClipRRect(borderRadius: radius, child: _fallback(context));
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, _) => AppShimmer(
          child: ShimmerBox(width: width, height: height ?? 100, borderRadius: BorderRadius.zero),
        ),
        errorWidget: (context, _, __) => _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(AppIcons.image, color: Theme.of(context).colorScheme.outline),
    );
  }
}
