// lib/src/presentation/screens/video_player/video_player_screen.dart
import 'dart:developer';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/video_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late PageController _pageController;
  final Map<int, BetterPlayerController> _controllers = {};
  late int _currentIndex;
  final int _preloadCount = 1;

  bool _wasPlayingBeforePause = false;

  @override
  void initState() {
    super.initState();
    log('VideoPlayerScreen initialized with ${widget.videos.length} videos');
    log(widget.videos.map((v) => v.title).toString());
    WidgetsBinding.instance.addObserver(this);

    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _initializeControllerForIndex(_currentIndex);
    final initialController = _controllers[_currentIndex];
    if (initialController != null) {
      initialController.addEventsListener((event) {
        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          if (mounted) {
            initialController.play();
          }
        }
      });
    }
    _preloadNextControllers();
    _setFullScreenMode();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final controller = _controllers[_currentIndex];
    if (controller == null) {
      return;
    }

    if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforePause) {
        controller.play();
      }
    } else {
      _wasPlayingBeforePause = controller.isPlaying() ?? false;

      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    final allControllers = _controllers.values.toList();
    for (var controller in allControllers) {
      controller.pause();
      controller.dispose();
    }
    _controllers.clear();

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

  /// ✅ Type-safe initialization - no more casting needed
  void _initializeControllerForIndex(int index) {
    if (index < 0 || index >= widget.videos.length) return;

    if (_controllers.containsKey(index)) {
      return;
    }

    final VideoModel video = widget.videos[index]; // ✅ Type-safe access

    // Get optimal video URL using the video sources
    String? videoUrl;

    try {
      // Use video sources if available, with fallback
      if (video.videoSources != null) {
        videoUrl = video.getOptimalVideoUrl(preferredQuality: '360p');
      } else {
        videoUrl = video.videoUrl;
      }

      if (videoUrl == null || videoUrl.isEmpty) {
        debugPrint('No valid video URL found for ${video.title}');
        return;
      }

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
        // Add quality resolutions if available
        resolutions: video.videoSources?.getQualityResolutionsMap(),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 30 * 1024 * 1024, // 30MB
          maxCacheFileSize: 10 * 1024 * 1024, // 10MB
        ),
      );

      final controller = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: false,
          autoDispose: false,
          looping: true,
          aspectRatio: 9 / 16,
          fit: BoxFit.cover,
          autoDetectFullscreenDeviceOrientation: false,
          handleLifecycle: true,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            showControls: false,
          ),
        ),
        betterPlayerDataSource: dataSource,
      );

      _controllers[index] = controller;
    } catch (e) {
      debugPrint('Failed to initialize video player for ${video.title}: $e');
    }
  }

  void _preloadNextControllers() {
    for (int i = 1; i <= _preloadCount; i++) {
      _initializeControllerForIndex(_currentIndex + i);
    }
  }

  void _disposeOldControllers() {
    final int lowerBound = _currentIndex - 1;
    final int upperBound = _currentIndex + _preloadCount;

    final List<int> keysToRemove = [];
    for (var key in _controllers.keys) {
      if (key < lowerBound || key > upperBound) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      final controller = _controllers.remove(key);
      controller?.dispose();
    }
  }

  void _onPageChanged(int index) {
    // Pause previous video
    final previousController = _controllers[_currentIndex];
    previousController?.pause();

    _currentIndex = index;

    // Play current video
    final currentController = _controllers[_currentIndex];
    currentController?.play();

    // Preload and cleanup
    _preloadNextControllers();
    _disposeOldControllers();

    // setState(() {});  //todo: icon will not change but let it be for now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          final controller = _controllers[index];
          final video = widget.videos[index];

          return Stack(
            fit: StackFit.expand,
            children: [
              // Video Player
              if (controller != null)
                BetterPlayer(controller: controller)
              else
                Container(
                  color: AppColors.background,
                  child: const Center(child: CircularProgressIndicator()),
                ),

              // Video Info Overlay (Bottom)
              Positioned(
                bottom: 100,
                left: 16,
                right: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (video.title?.isNotEmpty == true)
                      Text(
                        video.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (video.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        video.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Controls (Right side)
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  children: [
                    // Play/Pause button
                    GestureDetector(
                      onTap: () {
                        final controller = _controllers[_currentIndex];
                        if (controller?.isPlaying() == true) {
                          controller?.pause();
                        } else {
                          controller?.play();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Close button
              Positioned(
                top: 50,
                left: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
