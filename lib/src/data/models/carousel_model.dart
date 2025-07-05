import '../../domain/entities/carousel_entity.dart';
import 'video_model.dart';

class CarouselModel extends CarouselEntity {
  const CarouselModel({
    super.id,
    super.title,
    super.subtitle,
    super.displayType,
    super.priority,
    super.thumbnailStyle,
    super.showProgressBar,
    super.videos,
  });

  factory CarouselModel.fromJson(Map<String, dynamic> json) {
    return CarouselModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      displayType: json['display_type'] as String?,
      priority: json['priority'] as int?,
      thumbnailStyle: json['thumbnail_style'] as String?,
      showProgressBar: json['show_progress_bar'] as bool?,
      videos: (json['videos'] as List<dynamic>?)
          ?.map((video) => VideoModel.fromJson(video as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'display_type': displayType,
      'priority': priority,
      'thumbnail_style': thumbnailStyle,
      'show_progress_bar': showProgressBar,
      'videos': videos?.map((video) => (video as VideoModel).toJson()).toList(),
    };
  }
}
