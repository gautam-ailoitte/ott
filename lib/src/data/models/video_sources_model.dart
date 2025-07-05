class VideoQualityModel {
  final String? quality;
  final String? url;

  const VideoQualityModel({this.quality, this.url});

  factory VideoQualityModel.fromJson(Map<String, dynamic> json) {
    return VideoQualityModel(
      quality: json['quality'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'quality': quality, 'url': url};
  }
}

class VideoSourcesModel {
  final String? hlsManifest;
  final String? dashManifest;
  final List<VideoQualityModel>? progressive;

  const VideoSourcesModel({
    this.hlsManifest,
    this.dashManifest,
    this.progressive,
  });

  factory VideoSourcesModel.fromJson(Map<String, dynamic> json) {
    return VideoSourcesModel(
      hlsManifest: json['hls_manifest'] as String?,
      dashManifest: json['dash_manifest'] as String?,
      progressive: (json['progressive'] as List<dynamic>?)
          ?.map(
            (quality) =>
                VideoQualityModel.fromJson(quality as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hls_manifest': hlsManifest,
      'dash_manifest': dashManifest,
      'progressive': progressive?.map((quality) => quality.toJson()).toList(),
    };
  }

  /// Get the best video URL for playback (prioritizes HLS > DASH > Progressive)
  String? getBestVideoUrl() {
    // For Android, HLS works well with better_player
    if (hlsManifest != null && hlsManifest!.isNotEmpty) {
      return hlsManifest;
    }

    // Fallback to DASH
    if (dashManifest != null && dashManifest!.isNotEmpty) {
      return dashManifest;
    }

    // Fallback to progressive (prefer 360p for memory efficiency)
    if (progressive != null && progressive!.isNotEmpty) {
      // Try to find 360p first
      final quality360p = progressive!.firstWhere(
        (quality) => quality.quality?.toLowerCase().contains('360') == true,
        orElse: () => progressive!.first,
      );
      return quality360p.url;
    }

    return null;
  }

  /// Get specific quality URL from progressive sources
  String? getProgressiveUrl(String targetQuality) {
    if (progressive == null || progressive!.isEmpty) return null;

    final quality = progressive!.firstWhere(
      (q) =>
          q.quality?.toLowerCase().contains(targetQuality.toLowerCase()) ==
          true,
      orElse: () => progressive!.first,
    );

    return quality.url;
  }

  // 🎯 NEW: Better Player Integration Methods

  /// Get quality resolutions map for Better Player
  /// Returns Map<String, String> like {"360p": "url", "720p": "url"}
  Map<String, String> getQualityResolutionsMap() {
    if (progressive == null || progressive!.isEmpty) {
      return {};
    }

    final Map<String, String> resolutionsMap = {};

    for (final quality in progressive!) {
      if (quality.quality != null && quality.url != null) {
        resolutionsMap[quality.quality!] = quality.url!;
      }
    }

    return resolutionsMap;
  }

  /// Get the best quality URL available (highest resolution)
  String? getBestQualityUrl() {
    if (progressive == null || progressive!.isEmpty) {
      return getBestVideoUrl();
    }

    // Priority order: 720p > 480p > 360p > any available
    const qualityPriority = ['720p', '1080p', '480p', '360p'];

    for (final targetQuality in qualityPriority) {
      final url = getProgressiveUrl(targetQuality);
      if (url != null) {
        return url;
      }
    }

    // Fallback to first available
    return progressive!.first.url;
  }

  /// Check if multiple quality options are available
  bool get hasMultipleQualities {
    return progressive != null && progressive!.length > 1;
  }

  /// Get available quality labels
  List<String> get availableQualities {
    if (progressive == null) return [];

    return progressive!
        .where((quality) => quality.quality != null)
        .map((quality) => quality.quality!)
        .toList();
  }

  /// Get optimal URL for Better Player with fallback strategy
  String? getOptimalVideoUrl({String? preferredQuality}) {
    // 1. Try preferred quality if specified
    if (preferredQuality != null) {
      final preferredUrl = getProgressiveUrl(preferredQuality);
      if (preferredUrl != null) return preferredUrl;
    }

    // 2. Try HLS for adaptive streaming
    if (hlsManifest != null && hlsManifest!.isNotEmpty) {
      return hlsManifest;
    }

    // 3. Try DASH
    if (dashManifest != null && dashManifest!.isNotEmpty) {
      return dashManifest;
    }

    // 4. Fallback to best quality progressive
    return getBestQualityUrl();
  }

  /// Check if adaptive streaming (HLS/DASH) is available
  bool get hasAdaptiveStreaming {
    return (hlsManifest?.isNotEmpty == true) ||
        (dashManifest?.isNotEmpty == true);
  }
}
