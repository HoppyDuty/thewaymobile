import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../data/models/carousel_slide.dart';

class CarouselSection extends StatefulWidget {
  const CarouselSection({super.key, required this.slides});

  final List<CarouselSlide> slides;

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

/// Auto-advances one slide at a time on [_autoScrollInterval], pausing
/// while the user is dragging (or the app is backgrounded) and resuming
/// after. Looping is seamless — rather than a finite `PageView` that snaps
/// back to page 0 on wraparound, the controller starts deep into a
/// virtually-infinite page range and every index is taken mod
/// `slides.length`, so `nextPage()` never needs to jump backwards.
class _CarouselSectionState extends State<CarouselSection> with WidgetsBindingObserver {
  static const _autoScrollInterval = Duration(seconds: 5);
  static const _autoScrollAnimation = Duration(milliseconds: 450);
  // Large enough to swipe backwards indefinitely without hitting page 0
  // for any realistic session length, small enough to stay a plain int.
  static const _initialPageOffset = 5000;

  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final startPage = _initialPageOffset * (widget.slides.isEmpty ? 1 : widget.slides.length);
    _controller = PageController(viewportFraction: 0.92, initialPage: startPage);
    _page = startPage;
    _scheduleAutoScroll();
  }

  @override
  void didUpdateWidget(covariant CarouselSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) _scheduleAutoScroll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleAutoScroll();
    } else {
      _timer?.cancel();
    }
  }

  void _scheduleAutoScroll() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_controller.hasClients) return;
      _controller.nextPage(duration: _autoScrollAnimation, curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _onTap(CarouselSlide slide) {
    switch (slide.linkType) {
      case 'internal':
        if (slide.linkValue != null) context.push(slide.linkValue!);
      case 'external':
        if (slide.linkValue != null) {
          launchUrl(Uri.parse(slide.linkValue!), mode: LaunchMode.externalApplication);
        }
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: NotificationListener<ScrollNotification>(
            // A real user drag carries dragDetails; our own nextPage()
            // animation doesn't — so this pauses only for manual swipes
            // and resumes once the user lets go, without fighting the
            // auto-scroll's own programmatic page changes.
            onNotification: (notification) {
              if (notification is ScrollStartNotification && notification.dragDetails != null) {
                _timer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _scheduleAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final slide = widget.slides[index % widget.slides.length];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                  onTap: () => _onTap(slide),
                  child: ClipRRect(
                    borderRadius: AppRadius.lgRadius,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(url: slide.imageUrl, borderRadius: AppRadius.lgRadius),
                        // Scrim so the white overlay text stays legible
                        // regardless of the underlying image's own
                        // brightness/content (UI_UX_RULES.md §14).
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.lgRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.65)],
                                stops: const [0.4, 1.0],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: AppSpacing.md,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                slide.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (slide.subtitle != null)
                                Text(
                                  slide.subtitle!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.slides.length, (index) {
            final isActive = index == _page % widget.slides.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
