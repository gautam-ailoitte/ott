import 'package:ott/src/domain/entities/user_state_entity.dart';

import 'app_metadata_entity.dart';
import 'carousel_entity.dart';
import 'featured_content_entity.dart';

class HomeDataEntity {
  final AppMetadataEntity? metadata;
  final FeaturedContentEntity? featuredContent;
  final List<CarouselEntity>? carousels;
  final UserStateEntity? userState;

  const HomeDataEntity({
    this.metadata,
    this.featuredContent,
    this.carousels,
    this.userState,
  });
}
