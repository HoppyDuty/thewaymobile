import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';

/// Passed via go_router's `extra` when opening [LocalVideoPlayerScreen] from
/// "My Videos" — there's no server slug/lesson-id route to deep-link
/// through, just a local file.
class LocalVideoPlayerArgs {
  const LocalVideoPlayerArgs({required this.filePath, required this.title});

  final String filePath;
  final String title;
}

/// Plays a previously-downloaded lesson straight off local disk — no
/// network involved at all, unlike [VideoPlayerScreen] which streams from
/// YouTube via the iframe API.
class LocalVideoPlayerScreen extends StatefulWidget {
  const LocalVideoPlayerScreen({super.key, required this.filePath, required this.title});

  final String filePath;
  final String title;

  @override
  State<LocalVideoPlayerScreen> createState() => _LocalVideoPlayerScreenState();
}

class _LocalVideoPlayerScreenState extends State<LocalVideoPlayerScreen> {
  late final VideoPlayerController _controller;
  bool _fileMissing = false;

  @override
  void initState() {
    super.initState();
    final file = File(widget.filePath);
    if (!file.existsSync()) {
      _fileMissing = true;
      _controller = VideoPlayerController.file(file);
      return;
    }
    _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _fileMissing
          ? const AppErrorState(
              message: 'This downloaded file is missing. Try downloading it again.',
              icon: Icons.error_outline,
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: _controller.value.isInitialized
                        ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
                        : const CircularProgressIndicator(),
                  ),
                ),
                if (_controller.value.isInitialized) ...[
                  VideoProgressIndicator(_controller, allowScrubbing: true, padding: const EdgeInsets.all(AppSpacing.sm)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => IconButton(
                        iconSize: 40,
                        icon: Icon(_controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                        tooltip: _controller.value.isPlaying ? 'Pause' : 'Play',
                        onPressed: () => _controller.value.isPlaying ? _controller.pause() : _controller.play(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
