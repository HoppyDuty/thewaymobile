import 'package:flutter/material.dart';

/// A simple "G" monogram in Google's brand blue for the "Continue with
/// Google" button. Material's icon set has no Google logo (licensing), and
/// the app previously used `Icons.g_mobiledata_rounded` — a mobile-network-
/// signal icon, not a Google mark at all. This is a deliberately minimal,
/// safe replacement rather than a hand-drawn multi-color logomark that
/// can't be visually verified without a device.
class GoogleLogoMark extends StatelessWidget {
  const GoogleLogoMark({super.key, this.size = 20});

  final double size;

  static const _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size * 0.9,
            fontWeight: FontWeight.w700,
            color: _googleBlue,
            height: 1,
          ),
        ),
      ),
    );
  }
}
