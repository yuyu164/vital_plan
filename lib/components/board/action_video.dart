import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:chewie/chewie.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../api/action_video_source.dart';
import '../../viewmodels/action_model.dart';

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
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorText;
  double _brightnessValue = 0.5;
  double _volumeValue = 0.5;
  bool _adjustingBrightness = true;
  int? _activePointerId;
  double? _lastPointerGlobalY;
  String? _gestureLabel;
  Timer? _gestureOverlayTimer;

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
      final chewieController = ChewieController(
        videoPlayerController: player.controller,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: false,
      );

      if (!mounted) {
        chewieController.dispose();
        await player.dispose();
        return;
      }

      setState(() {
        _player = player;
        _chewieController = chewieController;
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
    final chewie = _chewieController;
    final player = _player;
    _chewieController = null;
    _player = null;
    chewie?.dispose();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_chewieController == null) {
      return Center(
        child: Text(
          _errorText ?? '暂无视频',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    final aspectRatio =
        _chewieController!.videoPlayerController.value.aspectRatio;
    return ColoredBox(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio == 0 ? 16 / 9 : aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  ),
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
