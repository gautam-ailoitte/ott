import '../../domain/entities/video_catalog_entity.dart';
import 'video_sources_model.dart';

class VideoCatalogModel extends VideoCatalogEntity {
  final VideoSourcesModel? videoSources;

  const VideoCatalogModel({
    super.id,
    super.title,
    super.videoUrl, // Keep for backward compatibility
    super.duration,
    super.nextVideoId,
    super.previousVideoId,
    super.playlistContext,
    this.videoSources,
  });

  factory VideoCatalogModel.fromJson(Map<String, dynamic> json) {
    final videoSources = json['video_sources'] != null
        ? VideoSourcesModel.fromJson(
            json['video_sources'] as Map<String, dynamic>,
          )
        : null;

    return VideoCatalogModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      // Use videoSources URL if available, fallback to old video_url for compatibility
      videoUrl: videoSources?.getBestVideoUrl() ?? json['video_url'] as String?,
      duration: json['duration'] as int?,
      nextVideoId: json['next_video_id'] as String?,
      previousVideoId: json['previous_video_id'] as String?,
      playlistContext: json['playlist_context'] as String?,
      videoSources: videoSources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_url': videoUrl,
      'video_sources': videoSources?.toJson(),
      'duration': duration,
      'next_video_id': nextVideoId,
      'previous_video_id': previousVideoId,
      'playlist_context': playlistContext,
    };
  }

  /// Get the optimal video URL for current device and network conditions
  String? getOptimalVideoUrl({String? preferredQuality}) {
    if (videoSources != null) {
      if (preferredQuality != null) {
        // Try to get specific quality first
        final progressiveUrl = videoSources!.getProgressiveUrl(
          preferredQuality,
        );
        if (progressiveUrl != null) return progressiveUrl;
      }

      // Fall back to best available URL
      return videoSources!.getBestVideoUrl();
    }

    // Fallback to legacy videoUrl
    return videoUrl;
  }

  /// Check if HLS/DASH adaptive streaming is available
  bool get hasAdaptiveStreaming {
    return videoSources?.hlsManifest != null ||
        videoSources?.dashManifest != null;
  }
}
