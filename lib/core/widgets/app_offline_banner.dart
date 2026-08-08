import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connectivity/connectivity_provider.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

/// Global "You're offline" banner (`uiuxrules.md` §8/§29). Debounces by
/// [AppDurations.offlineBannerDebounce] before appearing so a momentary
/// connectivity blip doesn't flash it on screen, and animates in/out
/// rather than popping abruptly.
///
/// Mount once near the root (see `app.dart`) — don't reimplement this
/// per-screen.
class AppOfflineBanner extends ConsumerStatefulWidget {
  const AppOfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppOfflineBanner> createState() => _AppOfflineBannerState();
}

class _AppOfflineBannerState extends ConsumerState<AppOfflineBanner> {
  bool _showBanner = false;
  Timer? _debounce;

  void _onConnectivityChanged(bool? previous, AsyncValue<bool> next) {
    final isOnline = next.valueOrNull;
    _debounce?.cancel();

    if (isOnline == null) return;

    if (isOnline) {
      setState(() => _showBanner = false);
      return;
    }

    _debounce = Timer(AppDurations.offlineBannerDebounce, () {
      if (mounted) setState(() => _showBanner = true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      _onConnectivityChanged(previous?.valueOrNull, next);
    });

    return Column(
      children: [
        AnimatedSize(
          duration: AppDurations.normal,
          curve: Curves.easeInOut,
          child: _showBanner ? _Banner() : const SizedBox(width: double.infinity),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.inverseSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 16, color: colorScheme.onInverseSurface),
              const SizedBox(width: AppSpacing.sm),
              Text(
                "You're offline — showing saved content.",
                style: TextStyle(color: colorScheme.onInverseSurface, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
