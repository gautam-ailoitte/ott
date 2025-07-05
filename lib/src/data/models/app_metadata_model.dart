import '../../domain/entities/app_metadata_entity.dart';

class AppMetadataModel extends AppMetadataEntity {
  const AppMetadataModel({
    super.version,
    super.lastUpdated,
    super.totalVideos,
    super.totalCarousels,
  });

  factory AppMetadataModel.fromJson(Map<String, dynamic> json) {
    return AppMetadataModel(
      version: json['version'] as String?,
      lastUpdated: json['last_updated'] as String?,
      totalVideos: json['total_videos'] as int?,
      totalCarousels: json['total_carousels'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'last_updated': lastUpdated,
      'total_videos': totalVideos,
      'total_carousels': totalCarousels,
    };
  }
}
