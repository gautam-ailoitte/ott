import '../../domain/entities/video_catalog_entity.dart';

class VideoCatalogModel extends VideoCatalogEntity {
  const VideoCatalogModel({
    super.id,
    super.title,
    super.videoUrl,
    super.duration,
    super.nextVideoId,
    super.previousVideoId,
    super.playlistContext,
  });

  factory VideoCatalogModel.fromJson(Map<String, dynamic> json) {
    return VideoCatalogModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      videoUrl: json['video_url'] as String?,
      duration: json['duration'] as int?,
      nextVideoId: json['next_video_id'] as String?,
      previousVideoId: json['previous_video_id'] as String?,
      playlistContext: json['playlist_context'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'video_url': videoUrl,
      'duration': duration,
      'next_video_id': nextVideoId,
      'previous_video_id': previousVideoId,
      'playlist_context': playlistContext,
    };
  }
}
