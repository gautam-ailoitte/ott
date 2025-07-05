import '../models/user_progress_model.dart';
import '../models/user_state_model.dart';

class UserDataSource {
  // In-memory storage for user state (simulating local storage)
  UserStateModel? _userState;
  final Map<String, UserProgressModel> _videoProgress = {};

  /// Get current user state
  UserStateModel? getUserState() {
    return _userState;
  }

  /// Update user state
  void updateUserState(UserStateModel userState) {
    _userState = userState;

    // Also update individual video progress map for quick access
    if (userState.videos != null) {
      for (final video in userState.videos!) {
        if (video.videoId != null) {
          _videoProgress[video.videoId!] = video as UserProgressModel;
        }
      }
    }
  }

  /// Get video progress by ID
  UserProgressModel? getVideoProgress(String videoId) {
    return _videoProgress[videoId];
  }

  /// Update video progress
  void updateVideoProgress(String videoId, UserProgressModel progress) {
    _videoProgress[videoId] = progress;

    // Update user state as well
    final currentVideos = _userState?.videos?.toList() ?? <UserProgressModel>[];
    final existingIndex = currentVideos.indexWhere((v) => v.videoId == videoId);

    if (existingIndex >= 0) {
      currentVideos[existingIndex] = progress;
    } else {
      currentVideos.add(progress);
    }

    _userState = UserStateModel(
      lastUpdated: DateTime.now().toIso8601String(),
      videos: currentVideos,
    );
  }

  /// Get continue watching video IDs
  List<String> getContinueWatchingVideoIds() {
    if (_userState?.videos == null) return [];

    return _userState!.videos!
        .where((video) => video.watchStatus == 'in_progress')
        .map((video) => video.videoId ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
  }

  /// Clear all user data
  void clearUserData() {
    _userState = null;
    _videoProgress.clear();
  }
}
