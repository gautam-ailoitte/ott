import 'package:ott/src/domain/entities/progress_data_entity.dart';

class VideoEntity {
  final String? id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final int? duration; // in seconds
  final String? category;
  final double? rating;
  final int? releaseYear;
  final String? contentType; // movie, series, short, documentary, etc.
  final String? thumbnailAspectRatio; // portrait, landscape, square
  final ProgressDataEntity? progressData;

  const VideoEntity({
    this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.duration,
    this.category,
    this.rating,
    this.releaseYear,
    this.contentType,
    this.thumbnailAspectRatio,
    this.progressData,
  });
}
