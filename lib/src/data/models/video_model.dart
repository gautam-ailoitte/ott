import '../../domain/entities/video_entity.dart';
import 'progress_data_model.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    super.id,
    super.title,
    super.description,
    super.thumbnailUrl,
    super.videoUrl,
    super.duration,
    super.category,
    super.rating,
    super.releaseYear,
    super.contentType,
    super.thumbnailAspectRatio,
    super.progressData,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration': duration,
      'category': category,
      'rating': rating,
      'release_year': releaseYear,
      'content_type': contentType,
      'thumbnail_aspect_ratio': thumbnailAspectRatio,
      'progress_data': (progressData as ProgressDataModel?)?.toJson(),
    };
  }
}
