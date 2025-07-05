// lib/src/presentation/screens/video_player/video_player_screen.dart
import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../injection_container.dart' as di;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/video_entity.dart';
import '../../cubits/video_player_cubit/video_player_cubit.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';

class VideoPlayerScreen extends StatelessWidget {
  final VideoEntity video;
  final List<VideoEntity>? playlist;
  final int? currentIndex;
  final String? playlistContext;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    this.playlist,
    this.currentIndex,
    this.playlistContext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<VideoPlayerCubit>()
        ..initializePlayer(
          video: video,
          playlist: playlist,
          currentIndex: currentIndex,
          playlistContext: playlistContext,
        ),
      child: const _VideoPlayerScreenView(),
    );
  }
}

class _VideoPlayerScreenView extends StatefulWidget {
  const _VideoPlayerScreenView();

  @override
  State<_VideoPlayerScreenView> createState() => _VideoPlayerScreenViewState();
}

class _VideoPlayerScreenViewState extends State<_VideoPlayerScreenView> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _setFullScreenMode();
  }

  @override
  void dispose() {
    debugPrint("--- Disposing VideoPlayerScreen ---");
    _restoreSystemUI();
    _pageController?.dispose();
    super.dispose();
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _handleBackButton() {
    debugPrint('Back button pressed');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<VideoPlayerCubit, VideoPlayerState>(
        listener: (context, state) {
          if (state is VideoPlayerReady) {
            // Initialize PageController once
            if (_pageController == null && state.playlist.isNotEmpty) {
              _pageController = PageController(initialPage: state.currentIndex);
              setState(() {}); // Trigger rebuild to show player
            }
          }
        },
        builder: (context, state) {
          if (state is VideoPlayerLoading) {
            return const Center(
              child: LoadingWidget(message: 'Loading video...'),
            );
          } else if (state is VideoPlayerReady) {
            return _buildVideoPlayer(context, state);
          } else if (state is VideoPlayerError) {
            return _buildErrorView(context, state.message);
          }
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, VideoPlayerReady state) {
    if (state.playlist.isEmpty) {
      return const Center(
        child: AppErrorWidget(message: 'No videos available'),
      );
    }

    // Handle single video case
    if (state.playlist.length == 1) {
      return VideoPage(
        video: state.playlist.first,
        onBack: _handleBackButton,
        onProgressUpdate: (videoId, position, duration) =>
            _updateProgress(context, videoId, position, duration),
      );
    }

    // Handle playlist case with PageView
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: state.playlist.length,
      itemBuilder: (context, index) {
        final video = state.playlist[index];
        return VideoPage(
          key: ValueKey('video_${video.id}_$index'),
          video: video,
          onBack: _handleBackButton,
          onProgressUpdate: (videoId, position, duration) =>
              _updateProgress(context, videoId, position, duration),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return AppErrorWidget(
      message: message,
      onRetry: () => Navigator.of(context).pop(),
    );
  }

  void _updateProgress(
    BuildContext context,
    String videoId,
    int position,
    int duration,
  ) {
    // Only update progress if context is still mounted
    if (mounted) {
      context.read<VideoPlayerCubit>().updateProgress(
        videoId: videoId,
        currentPosition: position,
        totalDuration: duration,
      );
    }
  }
}

// Individual Video Page Widget - Each manages its own controller
class VideoPage extends StatefulWidget {
  final VideoEntity video;
  final VoidCallback? onBack;
  final Function(String videoId, int position, int duration)? onProgressUpdate;

  const VideoPage({
    super.key,
    required this.video,
    this.onBack,
    this.onProgressUpdate,
  });

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  BetterPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    debugPrint('Disposing video controller for: ${widget.video.title}');
    _controller?.dispose();
    super.dispose();
  }

  void _initializeController() {
    if (widget.video.videoUrl == null) {
      debugPrint('Video URL is null for: ${widget.video.title}');
      return;
    }

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.videoUrl!,
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 10 * 1024 * 1024, // 10MB
        maxCacheSize: 100 * 1024 * 1024, // 100MB
        maxCacheFileSize: 50 * 1024 * 1024, // 50MB
      ),
    );

    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false, // Control via visibility
        autoDispose: true, // Let Better Player handle disposal
        looping: true,
        fit: BoxFit.cover,
        aspectRatio: 9 / 16, // TikTok aspect ratio
        allowedScreenSleep: false,
        handleLifecycle: true, // Built-in app lifecycle handling
        // playerVisibilityChangedBehavior:
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.custom,
          showControls: true,
          showControlsOnInitialize: false,
          controlsHideTime: const Duration(seconds: 3),
          enableFullscreen: true,
          enablePlaybackSpeed: false,
          enableSubtitles: false,
          enableAudioTracks: false,
          enableQualities: false,
          enablePip: false,
          enableRetry: true,
          enableMute: true,
          enablePlayPause: true,
          enableProgressBar: true,
          enableProgressText: true,
          customControlsBuilder: (ctrl, onVisibilityChanged) {
            return CustomVideoControls(
              controller: ctrl,
              video: widget.video,
              onBack: widget.onBack,
              onControlsVisibilityChanged: onVisibilityChanged,
              onProgressUpdate: widget.onProgressUpdate,
            );
          },
        ),
        eventListener: _handlePlayerEvent,
      ),
      betterPlayerDataSource: dataSource,
    );

    // Seek to saved position if available
    if (widget.video.progressData?.currentPosition != null) {
      final resumePosition = Duration(
        seconds: widget.video.progressData!.currentPosition!,
      );
      _controller!.seekTo(resumePosition);
    }

    setState(() {
      _isInitialized = true;
    });

    debugPrint('Initialized controller for: ${widget.video.title}');
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (!mounted || _controller == null) return;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.finished:
        widget.onProgressUpdate?.call(
          widget.video.id ?? '',
          widget.video.duration ?? 0,
          widget.video.duration ?? 0,
        );
        break;
      case BetterPlayerEventType.progress:
        if (event.parameters != null) {
          final Duration? progress = event.parameters!['progress'];
          final Duration? duration = event.parameters!['duration'];
          if (progress != null && duration != null) {
            widget.onProgressUpdate?.call(
              widget.video.id ?? '',
              progress.inSeconds,
              duration.inSeconds,
            );
          }
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: const Center(child: LoadingWidget(message: 'Loading video...')),
      );
    }

    return VisibilityDetector(
      key: Key('video_${widget.video.id}'),
      onVisibilityChanged: (visibilityInfo) {
        final visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage > 50) {
          // Video is more than 50% visible - play
          _controller?.play();
          debugPrint('Playing video: ${widget.video.title}');
        } else {
          // Video is less than 50% visible - pause
          _controller?.pause();
          debugPrint('Pausing video: ${widget.video.title}');
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: BetterPlayer(controller: _controller!),
      ),
    );
  }
}

// Custom Controls Widget
class CustomVideoControls extends StatefulWidget {
  final BetterPlayerController controller;
  final VideoEntity video;
  final VoidCallback? onBack;
  final Function(bool)? onControlsVisibilityChanged;
  final Function(String videoId, int position, int duration)? onProgressUpdate;

  const CustomVideoControls({
    super.key,
    required this.controller,
    required this.video,
    this.onBack,
    this.onControlsVisibilityChanged,
    this.onProgressUpdate,
  });

  @override
  State<CustomVideoControls> createState() => _CustomVideoControlsState();
}

class _CustomVideoControlsState extends State<CustomVideoControls>
    with TickerProviderStateMixin {
  bool _isVisible = true;
  Timer? _hideTimer;
  late AnimationController _animationController;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
    _startHideTimer();

    // Listen to player events
    widget.controller.addEventsListener(_handlePlayerEvent);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _handlePlayerEvent(BetterPlayerEvent event) {
    if (!mounted) return;

    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.progress:
        if (event.parameters != null) {
          final progress = event.parameters!['progress'] as Duration?;
          final duration = event.parameters!['duration'] as Duration?;
          if (progress != null && duration != null) {
            setState(() {
              _currentPosition = progress;
              _totalDuration = duration;
            });
            widget.onProgressUpdate?.call(
              widget.video.id ?? '',
              progress.inSeconds,
              duration.inSeconds,
            );
          }
        }
        break;
      case BetterPlayerEventType.initialized:
        if (event.parameters != null) {
          final duration = event.parameters!['duration'] as Duration?;
          if (duration != null) {
            setState(() {
              _totalDuration = duration;
            });
          }
        }
        break;
      default:
        break;
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  void _showControls() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
      widget.onControlsVisibilityChanged?.call(true);
    }
    _startHideTimer();
  }

  void _hideControls() {
    if (_isVisible) {
      setState(() => _isVisible = false);
      _animationController.reverse();
      widget.onControlsVisibilityChanged?.call(false);
    }
  }

  void _toggleControls() {
    if (_isVisible) {
      _hideControls();
    } else {
      _showControls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleControls,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Top Controls
            _buildTopControls(),
            // Center Play/Pause
            _buildCenterControls(),
            // Bottom Controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textPrimary,
                    size: AppDimensions.iconSizeL,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.title ?? 'Video',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.video.category != null)
                        Text(
                          widget.video.category!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterControls() {
    return Center(
      child: FadeTransition(
        opacity: _animationController,
        child: GestureDetector(
          onTap: () {
            if (widget.controller.isPlaying() ?? false) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
            _showControls();
          },
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.spaceL),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              (widget.controller.isPlaying() ?? false)
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
              color: AppColors.textPrimary,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Bar
                _buildProgressBar(),
                const SizedBox(height: AppDimensions.spaceS),
                // Duration and Instructions
                Row(
                  children: [
                    _buildTimeDisplay(),
                    const Spacer(),
                    Text(
                      AppStrings.swipeDownForNext,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.progressBackground,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        trackHeight: 3,
      ),
      child: Slider(
        value: _totalDuration.inMilliseconds > 0
            ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
                  .clamp(0.0, 1.0)
            : 0.0,
        onChanged: (value) {
          final newPosition = Duration(
            milliseconds: (value * _totalDuration.inMilliseconds).round(),
          );
          widget.controller.seekTo(newPosition);
        },
        onChangeStart: (_) => _hideTimer?.cancel(),
        onChangeEnd: (_) => _startHideTimer(),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Text(
      '${_currentPosition.inSeconds.toReadableDuration()} / ${_totalDuration.inSeconds.toReadableDuration()}',
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
