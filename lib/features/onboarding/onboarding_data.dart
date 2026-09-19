import 'package:flutter/material.dart';

/// Three short, benefit-focused slides (`UI_UX_RULES.md` / backend
/// `uiuxrules.md` §26). Currently icon-only — `rive`/`rive_native` was
/// removed (its Android build-time asset download is broken on Windows
/// paths containing a space, unfixed as of the latest release) and no
/// `.riv` files were ever shipped anyway. `lottie` remains a dependency if
/// a future pass wants real animated illustrations here.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}

const onboardingPages = [
  OnboardingPageData(
    icon: Icons.school_rounded,
    title: 'Study Anytime, Anywhere',
    subtitle:
        'Practice UTME, WAEC, Post-UTME and more — fully offline. Your questions and progress are always available, connection or not.',
  ),
  OnboardingPageData(
    icon: Icons.play_circle_rounded,
    title: 'Video Courses & Books',
    subtitle:
        'Learn from expert video courses and read your books offline — download once, study whenever it suits you.',
  ),
  OnboardingPageData(
    icon: Icons.auto_awesome_rounded,
    title: 'Meet Shepherd, Your AI Tutor',
    subtitle:
        'Get instant explanations, a personalised study plan, and guidance on the topics you find hardest.',
  ),
];
