import '../../domain/entities/progress_data_entity.dart';

class ProgressDataModel extends ProgressDataEntity {
  const ProgressDataModel({
    super.currentPosition,
    super.progressPercentage,
    super.lastWatched,
  });

  factory ProgressDataModel.fromJson(Map<String, dynamic> json) {
    return ProgressDataModel(
      currentPosition: json['current_position'] as int?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
      lastWatched: json['last_watched'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_position': currentPosition,
      'progress_percentage': progressPercentage,
      'last_watched': lastWatched,
    };
  }
}
