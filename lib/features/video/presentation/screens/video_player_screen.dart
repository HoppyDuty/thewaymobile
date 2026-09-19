import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../data/models/video_lesson.dart';
import '../../data/video_api.dart';
import '../providers/video_course_detail_controller.dart';

class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({super.key, required this.slug, required this.lessonId});

  final String slug;
  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoCourseDetailControllerProvider(slug));

    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: state.when(
        loading: () => const Center(child: CupertinoActivityIndicator(radius: 14)),
        error: (error, _) => AppErrorState(message: mapErrorToMessage(error)),
        data: (course) {
          final lesson = course.lessons.where((l) => l.id == lessonId).firstOrNull;
          if (lesson == null || !lesson.isPlayable) {
            return const AppErrorState(message: 'This lesson is not available.', icon: AppIcons.lock);
          }
          return _PlayerBody(courseId: course.id, lesson: lesson);
        },
      ),
    );
  }
}

class _PlayerBody extends ConsumerStatefulWidget {
  const _PlayerBody({required this.courseId, required this.lesson});

  final int courseId;
  final VideoLesson lesson;

  @override
  ConsumerState<_PlayerBody> createState() => _PlayerBodyState();
}

class _PlayerBodyState extends ConsumerState<_PlayerBody> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubeVideoState>? _stateSub;
  int _lastSavedSecond = 0;
  int _lastKnownSecond = 0;
  bool _completedSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.lesson.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true),
    );
    _stateSub = _controller.videoStateStream.listen(_onVideoState);
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _saveProgress(_lastKnownSecond);
    _controller.close();
    super.dispose();
  }

  void _onVideoState(YoutubeVideoState state) {
    final seconds = state.position.inSeconds;
    _lastKnownSecond = seconds;

    if (seconds - _lastSavedSecond >= 10) {
      _saveProgress(seconds);
    }
  }

  Future<void> _saveProgress(int watchedSeconds) async {
    if (watchedSeconds <= 0 || _completedSaved) return;
    _lastSavedSecond = watchedSeconds;
    try {
      await ref.read(videoApiProvider).saveProgress(
        lessonId: widget.lesson.id,
        courseId: widget.courseId,
        watchedSeconds: watchedSeconds,
        durationSeconds: widget.lesson.durationSeconds,
      );
    } catch (_) {
      // Best-effort — progress will catch up on the next successful save.
    }
  }

  Future<void> _onCompleted() async {
    if (_completedSaved) return;
    _completedSaved = true;
    try {
      await ref.read(videoApiProvider).saveProgress(
        lessonId: widget.lesson.id,
        courseId: widget.courseId,
        watchedSeconds: widget.lesson.durationSeconds,
        durationSeconds: widget.lesson.durationSeconds,
      );
    } catch (_) {
      _completedSaved = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: Column(
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          YoutubeValueBuilder(
            controller: _controller,
            buildWhen: (oldValue, newValue) => oldValue.playerState != newValue.playerState,
            builder: (context, value) {
              if (value.playerState == PlayerState.ended) {
                WidgetsBinding.instance.addPostFrameCallback((_) => _onCompleted());
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.lesson.title, style: theme.textTheme.titleMedium),
                  if (widget.lesson.description != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(widget.lesson.description!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
