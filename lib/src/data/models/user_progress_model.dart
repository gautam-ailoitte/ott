import '../../domain/entities/user_progress_entity.dart';

class UserProgressModel extends UserProgressEntity {
  const UserProgressModel({
    super.videoId,
    super.lastWatched,
    super.currentPosition,
    super.totalDuration,
    super.progressPercentage,
    super.watchStatus,
    super.watchCount,
    super.firstWatched,
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    return UserProgressModel(
      videoId: json['video_id'] as String?,
      lastWatched: json['last_watched'] as String?,
      currentPosition: json['current_position'] as int?,
      totalDuration: json['total_duration'] as int?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble(),
      watchStatus: json['watch_status'] as String?,
      watchCount: json['watch_count'] as int?,
      firstWatched: json['first_watched'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'video_id': videoId,
      'last_watched': lastWatched,
      'current_position': currentPosition,
      'total_duration': totalDuration,
      'progress_percentage': progressPercentage,
      'watch_status': watchStatus,
      'watch_count': watchCount,
      'first_watched': firstWatched,
    };
  }
}
