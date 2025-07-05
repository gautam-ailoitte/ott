import '../../domain/entities/home_data_entity.dart';
import 'app_metadata_model.dart';
import 'carousel_model.dart';
import 'featured_content_model.dart';
import 'user_state_model.dart';

class HomeDataModel extends HomeDataEntity {
  const HomeDataModel({
    super.metadata,
    super.featuredContent,
    super.carousels,
    super.userState,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      metadata: json['app_metadata'] != null
          ? AppMetadataModel.fromJson(
              json['app_metadata'] as Map<String, dynamic>,
            )
          : null,
      featuredContent: json['featured_content'] != null
          ? FeaturedContentModel.fromJson(
              json['featured_content'] as Map<String, dynamic>,
            )
          : null,
      carousels: (json['carousels'] as List<dynamic>?)
          ?.map(
            (carousel) =>
                CarouselModel.fromJson(carousel as Map<String, dynamic>),
          )
          .toList(),
      userState: json['user_state']?['recently_played'] != null
          ? UserStateModel.fromJson(
              json['user_state']['recently_played'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
