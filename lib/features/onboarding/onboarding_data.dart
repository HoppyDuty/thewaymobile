import 'package:flutter/material.dart';

class OnboardingPageData {
  const OnboardingPageData({
    required this.riveAsset,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
  });

  final String riveAsset;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
}

/// Three short, benefit-focused slides (`uiuxrules.md` §26). Each
/// references a `.riv` asset that doesn't exist yet — see
/// `RiveAnimationView`'s fallback behavior — so dropping the real files
/// into `assets/rive/` later is a one-line swap, no screen changes needed.
const onboardingPages = [
  OnboardingPageData(
    riveAsset: 'assets/rive/onboarding_offline_study.riv',
    fallbackIcon: Icons.school_rounded,
    title: 'Study Anytime, Anywhere',
    subtitle:
        'Practice UTME, WAEC, Post-UTME and more — fully offline. Your questions and progress are always available, connection or not.',
  ),
  OnboardingPageData(
    riveAsset: 'assets/rive/onboarding_video_books.riv',
    fallbackIcon: Icons.play_circle_rounded,
    title: 'Video Courses & Books',
    subtitle:
        'Learn from expert video courses and read your books offline — download once, study whenever it suits you.',
  ),
  OnboardingPageData(
    riveAsset: 'assets/rive/onboarding_shepherd.riv',
    fallbackIcon: Icons.auto_awesome_rounded,
    title: 'Meet Shepherd, Your AI Tutor',
    subtitle:
        'Get instant explanations, a personalised study plan, and guidance on the topics you find hardest.',
  ),
];
