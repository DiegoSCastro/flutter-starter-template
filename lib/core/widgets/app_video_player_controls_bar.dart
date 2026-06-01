import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../media/video_player_service.dart';
import '../theme/app_spacing.dart';

class AppVideoPlayerControlsBar extends StatelessWidget {
  const AppVideoPlayerControlsBar({
    super.key,
    required this.controller,
    required this.rawController,
    required this.isFullscreen,
    required this.isMuted,
    required this.playbackSpeed,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onSpeedSelected,
    required this.onFullscreenPressed,
  });

  final AppVideoPlayerController controller;
  final VideoPlayerController rawController;
  final bool isFullscreen;
  final bool isMuted;
  final double playbackSpeed;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onFullscreenPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        bottom: isFullscreen,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _VideoProgressBar(rawController: rawController),
              _ControlsRow(
                controller: controller,
                isFullscreen: isFullscreen,
                isMuted: isMuted,
                playbackSpeed: playbackSpeed,
                onTogglePlay: onTogglePlay,
                onToggleMute: onToggleMute,
                onSpeedSelected: onSpeedSelected,
                onFullscreenPressed: onFullscreenPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({required this.rawController});

  final VideoPlayerController rawController;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: VideoProgressIndicator(
        rawController,
        allowScrubbing: true,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        colors: VideoProgressColors(
          playedColor: Theme.of(context).colorScheme.primary,
          bufferedColor: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.4),
          backgroundColor: Colors.white24,
        ),
      ),
    );
  }
}

class _ControlsRow extends StatelessWidget {
  const _ControlsRow({
    required this.controller,
    required this.isFullscreen,
    required this.isMuted,
    required this.playbackSpeed,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onSpeedSelected,
    required this.onFullscreenPressed,
  });

  final AppVideoPlayerController controller;
  final bool isFullscreen;
  final bool isMuted;
  final double playbackSpeed;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final ValueChanged<double> onSpeedSelected;
  final VoidCallback onFullscreenPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            controller.value.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            color: Colors.white,
          ),
          tooltip: controller.value.isPlaying ? 'Pause' : 'Play',
          onPressed: onTogglePlay,
        ),
        IconButton(
          icon: Icon(
            isMuted
                ? Icons.volume_off_rounded
                : controller.value.volume < 0.5
                ? Icons.volume_down_rounded
                : Icons.volume_up_rounded,
            color: Colors.white,
          ),
          tooltip: isMuted ? 'Unmute' : 'Mute',
          onPressed: onToggleMute,
        ),
        Text(
          '${formatVideoDuration(controller.value.position)} / '
          '${formatVideoDuration(controller.value.duration)}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        const Spacer(),
        _PlaybackSpeedMenu(
          playbackSpeed: playbackSpeed,
          onSelected: onSpeedSelected,
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          icon: Icon(
            isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white,
            size: 28,
          ),
          tooltip: isFullscreen ? 'Exit full screen' : 'Full screen',
          onPressed: onFullscreenPressed,
        ),
      ],
    );
  }
}

class _PlaybackSpeedMenu extends StatelessWidget {
  const _PlaybackSpeedMenu({
    required this.playbackSpeed,
    required this.onSelected,
  });

  final double playbackSpeed;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      initialValue: playbackSpeed,
      tooltip: 'Playback speed',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final speed in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
          PopupMenuItem(value: speed, child: Text('${speed}x')),
      ],
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(
          '${playbackSpeed}x',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

String formatVideoDuration(Duration duration) {
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (duration.inHours > 0) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
