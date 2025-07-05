// lib/src/presentation/widgets/video_player/better_player_helper.dart

import 'package:better_player_plus/better_player_plus.dart'
    show
        BetterPlayerDataSource,
        BetterPlayerDataSourceType,
        BetterPlayerEvent,
        BetterPlayerConfiguration,
        BetterPlayerPlaylistConfiguration,
        BetterPlayerVideoFormat,
        BetterPlayerCacheConfiguration;
import 'package:flutter/material.dart';

import '../../../data/models/video_model.dart';

/// Helper class to convert VideoModel to BetterPlayerDataSource
/// with quality selection and streaming support
class BetterPlayerHelper {
  /// Create BetterPlayerDataSource from VideoModel with quality options
  static BetterPlayerDataSource createDataSource(
    VideoModel videoModel, {
    String? preferredQuality,
    Duration? startAt,
  }) {
    // Get optimal URL and quality map
    final primaryUrl =
        videoModel.videoSources?.getOptimalVideoUrl(
          preferredQuality: preferredQuality,
        ) ??
        videoModel.videoUrl;

    final qualityMap =
        videoModel.videoSources?.getQualityResolutionsMap() ?? {};

    if (primaryUrl == null) {
      throw Exception('No valid video URL found for ${videoModel.title}');
    }

    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      primaryUrl,
      // Quality selection for Better Player
      resolutions: qualityMap.isNotEmpty ? qualityMap : null,
      // Start position for continue watching
      // startAt: startAt,
      // Video format hint for better compatibility
      videoFormat: _getVideoFormat(primaryUrl),
    );
  }

  /// Create playlist of BetterPlayerDataSource from VideoModel list
  static List<BetterPlayerDataSource> createPlaylist(
    List<VideoModel> videoModels, {
    String? preferredQuality,
  }) {
    return videoModels.map((video) {
      // For continue watching, start from saved position
      final startAt = video.progressData?.currentPosition != null
          ? Duration(seconds: video.progressData!.currentPosition!)
          : null;

      return createDataSource(
        video,
        preferredQuality: preferredQuality,
        startAt: startAt,
      );
    }).toList();
  }

  /// Get Better Player configuration optimized for mobile
  static BetterPlayerConfiguration getConfiguration({
    bool autoPlay = true,
    bool fullScreenByDefault = true,
    bool handleLifecycle = true,
    Function(BetterPlayerEvent)? eventListener,
  }) {
    return BetterPlayerConfiguration(
      // Playback settings
      autoPlay: autoPlay,
      looping: false,
      fullScreenByDefault: fullScreenByDefault,

      // Mobile optimization
      handleLifecycle: handleLifecycle,
      allowedScreenSleep: false,
      autoDispose: false, // Manual disposal for better control
      // UI settings
      // showControlsOnInitialize: true,
      fit: BoxFit.cover,

      // Performance settings
      autoDetectFullscreenDeviceOrientation: true,
      autoDetectFullscreenAspectRatio: true,

      // Event handling
      eventListener: eventListener,

      // Error handling
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Video Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load video content',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get playlist configuration for reels-style navigation
  static BetterPlayerPlaylistConfiguration getPlaylistConfiguration({
    Duration nextVideoDelay = const Duration(milliseconds: 1000),
    bool loopVideos = false,
    int initialStartIndex = 0,
  }) {
    return BetterPlayerPlaylistConfiguration(
      nextVideoDelay: nextVideoDelay,
      loopVideos: loopVideos,
      initialStartIndex: initialStartIndex,
    );
  }

  /// Helper to determine video format from URL
  static BetterPlayerVideoFormat? _getVideoFormat(String url) {
    final uri = Uri.parse(url.toLowerCase());
    final path = uri.path.toLowerCase();

    if (path.contains('.m3u8')) {
      return BetterPlayerVideoFormat.hls;
    } else if (path.contains('.mpd')) {
      return BetterPlayerVideoFormat.dash;
    } else if (path.contains('.mp4')) {
      return BetterPlayerVideoFormat.other;
    }

    return null;
  }

  /// Get cache configuration for better performance
  static BetterPlayerCacheConfiguration getCacheConfiguration() {
    return BetterPlayerCacheConfiguration(
      useCache: true,
      preCacheSize: 10 * 1024 * 1024, // 10MB pre-cache
      maxCacheSize: 50 * 1024 * 1024, // 50MB max cache
      maxCacheFileSize: 25 * 1024 * 1024, // 25MB per file
      key: "ott_app_cache", // Persistent cache key
    );
  }

  /// Create data source with caching for better performance
  static BetterPlayerDataSource createCachedDataSource(
    VideoModel videoModel, {
    String? preferredQuality,
    Duration? startAt,
  }) {
    final primaryUrl =
        videoModel.videoSources?.getOptimalVideoUrl(
          preferredQuality: preferredQuality,
        ) ??
        videoModel.videoUrl;

    final qualityMap =
        videoModel.videoSources?.getQualityResolutionsMap() ?? {};

    if (primaryUrl == null) {
      throw Exception('No valid video URL found for ${videoModel.title}');
    }

    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      primaryUrl,
      resolutions: qualityMap.isNotEmpty ? qualityMap : null,
      // startAt: startAt,
      cacheConfiguration: getCacheConfiguration(),
      videoFormat: _getVideoFormat(primaryUrl),
    );
  }
}
