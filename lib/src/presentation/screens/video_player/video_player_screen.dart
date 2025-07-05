import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_model.dart';
import '../../../domain/entities/video_entity.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<VideoEntity> videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  // Map to store controllers for each video index. This is the core of the solution.
  final Map<int, BetterPlayerController> _controllers = {};
  late int _currentIndex;

  // The number of pages to preload ahead of the current page.
  final int _preloadCount = 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    // Initialize the first video and preload the next one.
    _initializeControllerForIndex(_currentIndex);
    _preloadNextControllers();

    _setFullScreenMode();
  }

  @override
  void dispose() {
    // Dispose all controllers in the map when the screen is disposed.
    _controllers.values.forEach((controller) {
      controller.dispose();
    });
    _pageController.dispose();
    _restoreSystemUI();
    super.dispose();
  }

  void _setFullScreenMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _restoreSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Initializes a controller for a specific index, if it's not already initialized.
  void _initializeControllerForIndex(int index) {
    if (index < 0 || index >= widget.videos.length) return;

    if (_controllers.containsKey(index)) {
      return; // Controller already exists.
    }

    final video = widget.videos[index];

    // Get optimal video URL using the new video sources
    String? videoUrl;

    if (video is VideoModel && video.videoSources != null) {
      // For assignment, prefer 360p for memory efficiency
      videoUrl = video.getOptimalVideoUrl(preferredQuality: '360p');
    } else {
      // Fallback to legacy videoUrl
      videoUrl = video.videoUrl;
    }

    if (videoUrl == null || videoUrl.isEmpty) return;

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      // Reduced cache configuration for assignment
      cacheConfiguration: const BetterPlayerCacheConfiguration(
        useCache: true,
        maxCacheSize: 30 * 1024 * 1024, // 30MB instead of 100MB
        maxCacheFileSize: 10 * 1024 * 1024, // 10MB instead of 20MB
      ),
    );

    final controller = BetterPlayerController(
      BetterPlayerConfiguration(
        // autoPlay should be false initially. We control playback manually.
        autoPlay: false,
        looping: true,
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        // For HLS/adaptive streams, better_player will handle quality switching automatically
        autoDetectFullscreenDeviceOrientation: false,
        // Minimalistic controls for a TikTok/Reels feel.
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false, // Hide default controls
        ),
      ),
      betterPlayerDataSource: dataSource,
    );

    // Store the controller in our map.
    _controllers[index] = controller;
  }

  /// Preloads controllers for the next [_preloadCount] pages.
  void _preloadNextControllers() {
    for (int i = 1; i <= _preloadCount; i++) {
      _initializeControllerForIndex(_currentIndex + i);
    }
  }

  /// Disposes controllers that are outside the visible/preloaded range.
  void _disposeOldControllers() {
    // The range of controllers to keep in memory.
    final int lowerBound = _currentIndex - 1;
    final int upperBound = _currentIndex + _preloadCount;

    final List<int> keysToDispose = [];
    _controllers.forEach((key, controller) {
      if (key < lowerBound || key > upperBound) {
        keysToDispose.add(key);
        controller.dispose();
      }
    });

    // Remove disposed controllers from the map.
    for (var key in keysToDispose) {
      _controllers.remove(key);
    }
  }

  /// Handles page changes, controlling video playback and preloading.
  void _onPageChanged(int index) {
    // Pause the previous video controller, if it exists.
    final previousController = _controllers[_currentIndex];
    previousController?.pause();
    previousController?.seekTo(Duration.zero); // Rewind

    setState(() {
      _currentIndex = index;
    });

    // Play the new current video.
    final currentController = _controllers[_currentIndex];
    currentController?.play();

    // Dispose old controllers and preload new ones.
    _disposeOldControllers();
    _preloadNextControllers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          // Get the controller from the map.
          final controller = _controllers[index];
          final video = widget.videos[index];

          if (controller == null) {
            // If controller is not ready, show a placeholder.
            return _buildLoadingPage(video);
          }

          // When the first frame is ready, start playback if it's the current page.
          controller.addEventsListener((event) {
            if (event.betterPlayerEventType ==
                BetterPlayerEventType.initialized) {
              if (_currentIndex == index) {
                controller.play();
              }
            }
          });

          return _VideoPage(controller: controller, video: video);
        },
      ),
    );
  }

  // A simple loading placeholder
  Widget _buildLoadingPage(VideoEntity video) {
    return Container(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // You could show a thumbnail here
          // if (video.thumbnailUrl != null)
          //   Image.network(video.thumbnailUrl!, fit: BoxFit.cover, width: double.infinity, height: double.infinity,),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          // Also render video info on the loading page for a better UX
          _buildVideoInfoOverlay(video),
        ],
      ),
    );
  }
}

/// A dedicated widget for a single video page.
class _VideoPage extends StatefulWidget {
  final BetterPlayerController controller;
  final VideoEntity video;

  const _VideoPage({required this.controller, required this.video});

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  bool _isMuted = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Listen to player events to update our custom UI state.
    widget.controller.addEventsListener(_onPlayerEvent);
    _isPlaying = widget.controller.isPlaying() ?? false;
    // _isMuted = widget.controller.getBetterPlayerDataSource()?.isMuted ?? false;
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (mounted) {
      setState(() {
        if (event.betterPlayerEventType == BetterPlayerEventType.play) {
          _isPlaying = true;
        } else if (event.betterPlayerEventType == BetterPlayerEventType.pause) {
          _isPlaying = false;
        }
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeEventsListener(_onPlayerEvent);
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      if (widget.controller.isPlaying()!) {
        widget.controller.pause();
      } else {
        widget.controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        widget.controller.setVolume(0);
      } else {
        widget.controller.setVolume(1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // The Video Player
          Center(
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: BetterPlayer(controller: widget.controller),
            ),
          ),

          // Custom Controls Overlay
          GestureDetector(
            onTap: _togglePlayback,
            child: Container(
              color: Colors.transparent, // Make the whole area tappable
              child: Center(
                // Show a play/pause icon that fades in and out
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Video Info and Back Button
          _buildVideoInfoOverlay(widget.video),

          // Mute Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new, // A more modern back icon
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for video info to avoid code duplication.
Widget _buildVideoInfoOverlay(VideoEntity video) {
  return Positioned(
    bottom: 20,
    left: 16,
    right: 80, // Give some space for action buttons on the right
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (video.title != null) ...[
          Text(
            video.title!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (video.description != null) ...[
          Text(
            video.description!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              shadows: [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Colors.black54,
                ),
              ],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    ),
  );
}
