import '../../domain/entities/user_state_entity.dart';
import 'user_progress_model.dart';

class UserStateModel extends UserStateEntity {
  const UserStateModel({super.lastUpdated, super.videos});

  factory UserStateModel.fromJson(Map<String, dynamic> json) {
    return UserStateModel(
      lastUpdated: json['last_updated'] as String?,
      videos: (json['videos'] as List<dynamic>?)
          ?.map(
            (video) =>
                UserProgressModel.fromJson(video as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_updated': lastUpdated,
      'videos': videos
          ?.map((video) => (video as UserProgressModel).toJson())
          .toList(),
    };
  }
}
