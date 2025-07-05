class FeaturedContentEntity {
  final String? id;
  final String? title;
  final String? description;
  final String? thumbnailUrl;
  final String? videoUrl;
  final String? backdropUrl;
  final int? duration;
  final String? category;
  final double? rating;
  final int? releaseYear;
  final String? contentType;

  const FeaturedContentEntity({
    this.id,
    this.title,
    this.description,
    this.thumbnailUrl,
    this.videoUrl,
    this.backdropUrl,
    this.duration,
    this.category,
    this.rating,
    this.releaseYear,
    this.contentType,
  });
}
