import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../api/action_video_source.dart';
import '../../viewmodels/action_model.dart';

const Duration _kControlsAutoHideDelay = Duration(seconds: 3);

class ActionVideo extends StatefulWidget {
  final ActionModel action;

  const ActionVideo({Key? key, required this.action}) : super(key: key);

  @override
  State<ActionVideo> createState() => _ActionVideoState();
}

class _ActionVideoState extends State<ActionVideo> {
  final ScreenBrightness _screenBrightness = ScreenBrightness();
  final VolumeController _volumeController = VolumeController();
  CachedVideoPlayerPlus? _player;
  bool _isLoading = true;
  String? _errorText;
  double _brightnessValue = 0.5;
  double _volumeValue = 0.5;
  bool _adjustingBrightness = true;
  int? _activePointerId;
  double? _lastPointerGlobalY;
  String? _gestureLabel;
  Timer? _gestureOverlayTimer;
  Timer? _controlsOverlayTimer;
  bool _showPlaybackControls = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceLevels();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(covariant ActionVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action.id != widget.action.id) {
      _initializeVideo();
    }
  }

  @override
  void dispose() {
    _gestureOverlayTimer?.cancel();
    _controlsOverlayTimer?.cancel();
    _disposeControllers();
    super.dispose();
  }

  Future<void> _loadDeviceLevels() async {
    try {
      final brightness = await _screenBrightness.current;
      if (mounted) {
        setState(() {
          _brightnessValue = _clamp01(brightness);
        });
      }
    } catch (_) {}

    try {
      _volumeController.showSystemUI = false;
      final volume = await _volumeController.getVolume();
      if (mounted) {
        setState(() {
          _volumeValue = _clamp01(volume);
        });
      }
    } catch (_) {}
  }

  Future<void> _initializeVideo() async {
    _disposeControllers();
    final uri = ActionVideoSource.playableVideoUriOf(widget.action.id);
    if (uri == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText = '视频地址待配置';
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final cachePolicy = ActionVideoSource.cachePolicyOf(widget.action.id);
    final player = CachedVideoPlayerPlus.networkUrl(
      uri,
      invalidateCacheIfOlderThan: cachePolicy.maxCacheAge,
    );

    try {
      await player.initialize();
      if (!mounted) {
        await player.dispose();
        return;
      }

      setState(() {
        _player = player;
        _isLoading = false;
        _errorText = null;
      });
    } catch (_) {
      await player.dispose();
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorText = '视频加载失败';
      });
    }
  }

  void _disposeControllers() {
    final player = _player;
    _player = null;
    player?.dispose();
  }

  double _clamp01(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  void _onPointerDown(PointerDownEvent event, double width) {
    if (_activePointerId != null) {
      return;
    }
    _gestureOverlayTimer?.cancel();
    _activePointerId = event.pointer;
    _lastPointerGlobalY = event.position.dy;
    _adjustingBrightness = event.localPosition.dx <= width / 2;
  }

  Future<void> _onPointerMove(PointerMoveEvent event) async {
    if (_activePointerId != event.pointer) {
      return;
    }
    if (event.delta.dy.abs() < event.delta.dx.abs()) {
      return;
    }

    final lastY = _lastPointerGlobalY;
    if (lastY == null) {
      _lastPointerGlobalY = event.position.dy;
      return;
    }
    _lastPointerGlobalY = event.position.dy;
    final deltaY = lastY - event.position.dy;
    final step = deltaY / 240;
    if (step == 0) {
      return;
    }

    if (_adjustingBrightness) {
      final next = _clamp01(_brightnessValue + step);
      _brightnessValue = next;
      try {
        await _screenBrightness.setScreenBrightness(next);
      } catch (_) {}
      if (mounted) {
        setState(() {
          _gestureLabel = '亮度 ${(next * 100).round()}%';
        });
      }
      return;
    }

    final next = _clamp01(_volumeValue + step);
    _volumeValue = next;
    try {
      _volumeController.setVolume(next, showSystemUI: false);
    } catch (_) {}
    if (mounted) {
      setState(() {
        _gestureLabel = '音量 ${(next * 100).round()}%';
      });
    }
  }

  void _onVerticalDragEnd() {
    _activePointerId = null;
    _lastPointerGlobalY = null;
    _gestureOverlayTimer?.cancel();
    _gestureOverlayTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _gestureLabel = null;
      });
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause(VideoPlayerController controller) async {
    if (controller.value.isPlaying) {
      await controller.pause();
      _controlsOverlayTimer?.cancel();
      if (mounted) {
        setState(() {
          _showPlaybackControls = true;
        });
      }
      return;
    }
    await controller.play();
    _showControls(controller);
  }

  Future<void> _seekBy(VideoPlayerController controller, int seconds) async {
    final target = controller.value.position + Duration(seconds: seconds);
    final duration = controller.value.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);
    await controller.seekTo(clamped);
    _showControls(controller);
  }

  Future<void> _openFullScreen(VideoPlayerController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ActionVideoFullScreen(controller: controller),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleControlsAutoHide(VideoPlayerController controller) {
    _controlsOverlayTimer?.cancel();
    if (!controller.value.isPlaying) {
      return;
    }
    _controlsOverlayTimer = Timer(_kControlsAutoHideDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showPlaybackControls = false;
      });
    });
  }

  void _showControls(VideoPlayerController controller) {
    if (!mounted) {
      return;
    }
    setState(() {
      _showPlaybackControls = true;
    });
    _scheduleControlsAutoHide(controller);
  }

  void _toggleControlsVisibility(VideoPlayerController controller) {
    if (_showPlaybackControls) {
      _controlsOverlayTimer?.cancel();
      setState(() {
        _showPlaybackControls = false;
      });
      return;
    }
    _showControls(controller);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final cachedPlayer = _player;
    if (cachedPlayer == null) {
      return Center(
        child: Text(
          _errorText ?? '暂无视频',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final playerController = cachedPlayer.controller;
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (event) =>
                _onPointerDown(event, constraints.maxWidth),
            onPointerMove: _onPointerMove,
            onPointerUp: (_) => _onVerticalDragEnd(),
            onPointerCancel: (_) => _onVerticalDragEnd(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<VideoPlayerValue>(
                  valueListenable: playerController,
                  builder: (context, value, child) {
                    if (!value.isInitialized) {
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    }
                    final videoWidth = value.size.width == 0
                        ? constraints.maxWidth
                        : value.size.width;
                    final videoHeight = value.size.height == 0
                        ? constraints.maxHeight
                        : value.size.height;
                    final durationMs = value.duration.inMilliseconds <= 0
                        ? 1.0
                        : value.duration.inMilliseconds.toDouble();
                    final positionMs = value.position.inMilliseconds
                        .toDouble()
                        .clamp(0.0, durationMs);

                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRect(
                          child: SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: videoWidth,
                                height: videoHeight,
                                child: VideoPlayer(playerController),
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () =>
                                _toggleControlsVisibility(playerController),
                          ),
                        ),
                        IgnorePointer(
                          ignoring: !_showPlaybackControls,
                          child: AnimatedOpacity(
                            opacity: _showPlaybackControls ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(color: Colors.black26),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _seekBy(playerController, -10),
                                        icon: const Icon(
                                          Icons.replay_10,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            _togglePlayPause(playerController),
                                        icon: Icon(
                                          value.isPlaying
                                              ? Icons.pause_circle_filled
                                              : Icons.play_circle_fill,
                                          color: Colors.white,
                                          size: 52,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: () =>
                                            _seekBy(playerController, 10),
                                        icon: const Icon(
                                          Icons.forward_10,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  right: 12,
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            _formatDuration(value.position),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: SliderTheme(
                                              data: SliderTheme.of(context)
                                                  .copyWith(
                                                    thumbShape:
                                                        const RoundSliderThumbShape(
                                                          enabledThumbRadius: 5,
                                                        ),
                                                    trackHeight: 3,
                                                  ),
                                              child: Slider(
                                                value: positionMs,
                                                min: 0,
                                                max: durationMs,
                                                onChanged: (next) {
                                                  playerController.seekTo(
                                                    Duration(
                                                      milliseconds: next
                                                          .toInt(),
                                                    ),
                                                  );
                                                  _showControls(
                                                    playerController,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDuration(value.duration),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () => _openFullScreen(
                                              playerController,
                                            ),
                                            icon: const Icon(
                                              Icons.fullscreen,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                if (_gestureLabel != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        _gestureLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionVideoFullScreen extends StatefulWidget {
  final VideoPlayerController controller;

  const _ActionVideoFullScreen({required this.controller});

  @override
  State<_ActionVideoFullScreen> createState() => _ActionVideoFullScreenState();
}

class _ActionVideoFullScreenState extends State<_ActionVideoFullScreen> {
  Timer? _controlsTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _scheduleAutoHide();
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayPause() async {
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
      _controlsTimer?.cancel();
      if (mounted) {
        setState(() {
          _showControls = true;
        });
      }
      return;
    }
    await widget.controller.play();
    _showControlsTemporarily();
  }

  Future<void> _seekBy(int seconds) async {
    final target =
        widget.controller.value.position + Duration(seconds: seconds);
    final duration = widget.controller.value.duration;
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > duration ? duration : target);
    await widget.controller.seekTo(clamped);
    _showControlsTemporarily();
  }

  void _scheduleAutoHide() {
    _controlsTimer?.cancel();
    if (!widget.controller.value.isPlaying) {
      return;
    }
    _controlsTimer = Timer(_kControlsAutoHideDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showControls = false;
      });
    });
  }

  void _showControlsTemporarily() {
    if (!mounted) {
      return;
    }
    setState(() {
      _showControls = true;
    });
    _scheduleAutoHide();
  }

  void _toggleControlsVisibility() {
    if (_showControls) {
      _controlsTimer?.cancel();
      setState(() {
        _showControls = false;
      });
      return;
    }
    _showControlsTemporarily();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ValueListenableBuilder<VideoPlayerValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            final durationMs = value.duration.inMilliseconds <= 0
                ? 1.0
                : value.duration.inMilliseconds.toDouble();
            final positionMs = value.position.inMilliseconds.toDouble().clamp(
              0.0,
              durationMs,
            );
            return Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: value.aspectRatio == 0
                        ? 16 / 9
                        : value.aspectRatio,
                    child: VideoPlayer(widget.controller),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: _toggleControlsVisibility,
                  ),
                ),
                IgnorePointer(
                  ignoring: !_showControls,
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(color: Colors.black26),
                        Positioned(
                          left: 8,
                          top: 8,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () => _seekBy(-10),
                              icon: const Icon(
                                Icons.replay_10,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                value.isPlaying
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_fill,
                                color: Colors.white,
                                size: 58,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => _seekBy(10),
                              icon: const Icon(
                                Icons.forward_10,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Row(
                            children: [
                              Text(
                                _formatDuration(value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 5,
                                    ),
                                    trackHeight: 3,
                                  ),
                                  child: Slider(
                                    value: positionMs,
                                    min: 0,
                                    max: durationMs,
                                    onChanged: (next) {
                                      widget.controller.seekTo(
                                        Duration(milliseconds: next.toInt()),
                                      );
                                      _showControlsTemporarily();
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatDuration(value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
