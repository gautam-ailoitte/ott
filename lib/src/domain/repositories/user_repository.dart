import '../entities/user_progress_entity.dart';
import '../entities/user_state_entity.dart';

abstract class UserRepository {
  /// Save video progress to memory/local storage
  Future<void> saveVideoProgress(
    String videoId,
    int currentPosition,
    int totalDuration,
  );

  /// Get video progress
  Future<UserProgressEntity?> getVideoProgress(String videoId);

  /// Get all user progress data
  Future<UserStateEntity> getUserState();

  /// Update user state
  Future<void> updateUserState(UserStateEntity userState);

  /// Mark video as completed
  Future<void> markVideoAsCompleted(String videoId);

  /// Get continue watching list
  Future<List<String>> getContinueWatchingVideoIds();
}
