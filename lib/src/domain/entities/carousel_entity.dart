import 'package:ott/src/domain/entities/video_entity.dart';

class CarouselEntity {
  final String? id;
  final String? title;
  final String? subtitle;
  final String? displayType;
  final int? priority;
  final String? thumbnailStyle;
  final bool? showProgressBar;
  final List<VideoEntity>? videos;

  const CarouselEntity({
    this.id,
    this.title,
    this.subtitle,
    this.displayType,
    this.priority,
    this.thumbnailStyle,
    this.showProgressBar,
    this.videos,
  });
}
