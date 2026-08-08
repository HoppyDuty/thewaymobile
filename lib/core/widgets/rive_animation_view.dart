import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

/// Loads and plays a `.riv` file, falling back gracefully to [fallback] if
/// the asset is missing or fails to load — so a screen that references an
/// animation that hasn't landed yet (or fails to parse) never crashes.
///
/// Usage: drop a real file at `assets/rive/<name>.riv` (already declared
/// as an asset directory in `pubspec.yaml`) and pass
/// `assetPath: 'assets/rive/<name>.riv'`.
class RiveAnimationView extends StatefulWidget {
  const RiveAnimationView({
    super.key,
    required this.assetPath,
    this.fallback,
    this.fit = rive.Fit.contain,
  });

  final String assetPath;
  final Widget? fallback;
  final rive.Fit fit;

  @override
  State<RiveAnimationView> createState() => _RiveAnimationViewState();
}

class _RiveAnimationViewState extends State<RiveAnimationView> {
  rive.File? _file;
  rive.RiveWidgetController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RiveAnimationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _disposeCurrent();
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final file = await rive.File.asset(widget.assetPath, riveFactory: rive.Factory.rive);
      if (file == null) {
        if (mounted) setState(() => _failed = true);
        return;
      }
      if (!mounted) {
        file.dispose();
        return;
      }
      setState(() {
        _file = file;
        _controller = rive.RiveWidgetController(file);
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _disposeCurrent() {
    _controller?.dispose();
    _file?.dispose();
    _controller = null;
    _file = null;
  }

  @override
  void dispose() {
    _disposeCurrent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallback ?? const SizedBox.shrink();
    if (_controller == null) return widget.fallback ?? const SizedBox.shrink();
    return rive.RiveWidget(controller: _controller!, fit: widget.fit);
  }
}
