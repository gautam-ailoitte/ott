import '../../domain/entities/video_entity.dart';
import 'progress_data_model.dart';
import 'video_sources_model.dart';

class VideoModel extends VideoEntity {
  final VideoSourcesModel? videoSources;

  const VideoModel({
    super.id,
    super.title,
    super.description,
    super.thumbnailUrl,
    super.videoUrl, // Keep for backward compatibility
    super.duration,
    super.category,
    super.rating,
    super.releaseYear,
    super.contentType,
    super.thumbnailAspectRatio,
    super.progressData,
    this.videoSources,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final videoSources = json['video_sources'] != null
        ? VideoSourcesModel.fromJson(
            json['video_sources'] as Map<String, dynamic>,
          )
        : null;

    return VideoModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      // Use videoSources URL if available, fallback to old video_url for compatibility
      videoUrl: videoSources?.getBestVideoUrl() ?? json['video_url'] as String?,
      duration: json['duration'] as int?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      releaseYear: json['release_year'] as int?,
      contentType: json['content_type'] as String?,
      thumbnailAspectRatio: json['thumbnail_aspect_ratio'] as String?,
      progressData: json['progress_data'] != null
          ? ProgressDataModel.fromJson(
              json['progress_data'] as Map<String, dynamic>,
            )
          : null,
      videoSources: videoSources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'video_sources': videoSources?.toJson(),
      'duration': duration,
      'category': category,
      'rating': rating,
      'release_year': releaseYear,
      'content_type': contentType,
      'thumbnail_aspect_ratio': thumbnailAspectRatio,
      'progress_data': (progressData as ProgressDataModel?)?.toJson(),
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

  /// Get available quality options
  List<String> get availableQualities {
    if (videoSources?.progressive == null) return [];

    return videoSources!.progressive!
        .where((quality) => quality.quality != null)
        .map((quality) => quality.quality!)
        .toList();
  }
}
