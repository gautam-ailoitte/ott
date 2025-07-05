import '../../domain/entities/featured_content_entity.dart';

class FeaturedContentModel extends FeaturedContentEntity {
  const FeaturedContentModel({
    super.id,
    super.title,
    super.description,
    super.thumbnailUrl,
    super.videoUrl,
    super.backdropUrl,
    super.duration,
    super.category,
    super.rating,
    super.releaseYear,
    super.contentType,
  });

  factory FeaturedContentModel.fromJson(Map<String, dynamic> json) {
    return FeaturedContentModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String?,
      backdropUrl: json['backdrop_url'] as String?,
      duration: json['duration'] as int?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      releaseYear: json['release_year'] as int?,
      contentType: json['content_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'backdrop_url': backdropUrl,
      'duration': duration,
      'category': category,
      'rating': rating,
      'release_year': releaseYear,
      'content_type': contentType,
    };
  }
}
