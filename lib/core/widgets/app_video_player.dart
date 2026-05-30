import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import '../animation/app_durations.dart';
import '../media/video_player_service.dart';
import '../theme/app_icon_size.dart';
import '../theme/app_spacing.dart';

/// A premium, highly customizable, and responsive video player widget.
///
/// Wraps [AppVideoPlayerController] and provides beautiful glassmorphic controls,
/// auto-hiding overlay HUD, speed adjustment, volume controls, buffering/error views,
/// and smooth animations.
class AppVideoPlayer extends StatefulWidget {
  /// Creates an instance of [AppVideoPlayer].
  const AppVideoPlayer({
    super.key,
    required this.controller,
    this.aspectRatio,
    this.isFullscreen = false,
  });

  /// The video controller interface.
  final AppVideoPlayerController controller;

  /// Optional override for the video aspect ratio.
  /// If not provided, the controller's initialized aspect ratio is used.
  final double? aspectRatio;

  /// Whether this player is currently rendering in fullscreen mode.
  final bool isFullscreen;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  bool _showControls = true;
  Timer? _hideTimer;
  double _playbackSpeed = 1;
  bool _isMuted = false;
  double _preMuteVolume = 1;

  @override
  void initState() {
    super.initState();
    widget.controller.valueListenable.addListener(_onControllerValueChanged);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.valueListenable.removeListener(_onControllerValueChanged);
    super.dispose();
  }

  void _onControllerValueChanged() {
    if (mounted) {
      setState(() {
        _playbackSpeed = widget.controller.value.playbackSpeed;
        _isMuted = widget.controller.value.volume == 0.0;
      });
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _onTapPlayer() {
    _toggleControls();
  }

  Future<void> _togglePlay() async {
    _startHideTimer();
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
  }

  Future<void> _toggleMute() async {
    _startHideTimer();
    final currentVolume = widget.controller.value.volume;
    if (currentVolume > 0) {
      _preMuteVolume = currentVolume;
      await widget.controller.setVolume(0);
    } else {
      await widget.controller.setVolume(_preMuteVolume);
    }
  }

  void _setSpeed(double speed) {
    _startHideTimer();
    widget.controller.setPlaybackSpeed(speed);
  }

  void _enterFullscreen() {
    if (widget.isFullscreen) {
      Navigator.of(context).pop();
    } else {
      _AppVideoPlayerFullScreenPage.show(context, widget.controller);
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.controller.rawController;
    if (raw == null) {
      // Return placeholder widget when controller is mocked or stubbed for testing.
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library, color: Colors.white70, size: 48),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Mock Video Player View',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (!widget.controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: widget.controller.value.hasError
              ? _buildErrorView()
              : const CircularProgressIndicator(),
        ),
      );
    }

    final resolvedAspectRatio =
        widget.aspectRatio ?? widget.controller.value.aspectRatio;

    return AspectRatio(
      aspectRatio: resolvedAspectRatio,
      child: GestureDetector(
        onTap: _onTapPlayer,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Underlying Video View
            IgnorePointer(child: VideoPlayer(raw)),

            // Loading/Buffering Indicator
            if (widget.controller.value.isBuffering)
              const CircularProgressIndicator().animate().fade(
                duration: AppDurations.xfast,
              ),

            // Controls HUD Overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: AppDurations.fast,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _buildControlsOverlay(context, raw),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: AppIconSize.xxxl,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.controller.value.errorDescription ?? 'Failed to load video',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildControlsOverlay(
    BuildContext context,
    VideoPlayerController raw,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Top HUD row (close if full screen)
          if (widget.isFullscreen)
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),

          // Central Play/Pause Tap Target Overlay. Hidden from semantics: the
          // labeled play/pause button in the controls row covers screen readers
          // so this redundant gesture target doesn't announce twice.
          Center(
            child: ExcludeSemantics(
              child:
                  Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _togglePlay,
                          customBorder: const CircleBorder(),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      )
                      .animate(
                        target: widget.controller.value.isPlaying ? 1 : 0,
                      )
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 150.ms,
                      )
                      .fade(duration: 150.ms),
            ),
          ),

          // Bottom Controls HUD Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              bottom: widget.isFullscreen,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Video Progress Track
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: VideoProgressIndicator(
                        raw,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        colors: VideoProgressColors(
                          playedColor: Theme.of(context).colorScheme.primary,
                          bufferedColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ),

                    // Controls Row
                    Row(
                      children: [
                        // Play/Pause Action
                        IconButton(
                          icon: Icon(
                            widget.controller.value.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          tooltip: widget.controller.value.isPlaying
                              ? 'Pause'
                              : 'Play',
                          onPressed: _togglePlay,
                        ),

                        // Volume Toggle + Value control
                        IconButton(
                          icon: Icon(
                            _isMuted
                                ? Icons.volume_off_rounded
                                : widget.controller.value.volume < 0.5
                                ? Icons.volume_down_rounded
                                : Icons.volume_up_rounded,
                            color: Colors.white,
                          ),
                          tooltip: _isMuted ? 'Unmute' : 'Mute',
                          onPressed: _toggleMute,
                        ),

                        // Timeline Clock (Elapsed / Duration)
                        Text(
                          '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),

                        const Spacer(),

                        // Playback Speed Button
                        PopupMenuButton<double>(
                          initialValue: _playbackSpeed,
                          tooltip: 'Playback speed',
                          onSelected: _setSpeed,
                          itemBuilder: (context) => [
                            for (final speed in [
                              0.5,
                              0.75,
                              1.0,
                              1.25,
                              1.5,
                              2.0,
                            ])
                              PopupMenuItem(
                                value: speed,
                                child: Text('${speed}x'),
                              ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              '${_playbackSpeed}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        // Fullscreen Action
                        IconButton(
                          icon: Icon(
                            widget.isFullscreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          tooltip: widget.isFullscreen
                              ? 'Exit full screen'
                              : 'Full screen',
                          onPressed: _enterFullscreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppVideoPlayerFullScreenPage extends StatefulWidget {
  const _AppVideoPlayerFullScreenPage({required this.controller});

  final AppVideoPlayerController controller;

  static Future<void> show(
    BuildContext context,
    AppVideoPlayerController controller,
  ) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, _, _) =>
            _AppVideoPlayerFullScreenPage(controller: controller),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<_AppVideoPlayerFullScreenPage> createState() =>
      _AppVideoPlayerFullScreenPageState();
}

class _AppVideoPlayerFullScreenPageState
    extends State<_AppVideoPlayerFullScreenPage> {
  @override
  void initState() {
    super.initState();
    // Configure immersive video settings
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Restore default portrait display settings
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AppVideoPlayer(
          controller: widget.controller,
          isFullscreen: true,
        ),
      ),
    );
  }
}
