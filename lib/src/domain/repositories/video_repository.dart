import '../../data/models/video_model.dart'; // Import VideoModel for return types
import '../entities/home_data_entity.dart';
import '../entities/user_progress_entity.dart';
import '../entities/video_catalog_entity.dart';

abstract class VideoRepository {
  /// Get all home screen data including carousels and featured content
  Future<HomeDataEntity> getHomeData();

  /// Get videos by category - Returns VideoModel for Better Player integration
  Future<List<VideoModel>> getVideosByCategory(String category);

  /// Get video details by ID - Returns VideoModel for quality selection
  Future<VideoModel?> getVideoById(String id);

  /// Get video catalog entry for navigation
  Future<VideoCatalogEntity?> getVideoCatalogById(String id);

  /// Get playlist videos for navigation - Returns VideoModel for player
  Future<List<VideoModel>> getPlaylistVideos(String playlistId);

  /// Get navigation playlists
  Future<Map<String, List<String>>> getNavigationPlaylists();

  /// Update video progress
  Future<void> updateVideoProgress(String videoId, UserProgressEntity progress);

  /// Get user's watch history
  Future<List<UserProgressEntity>> getUserProgress();

  /// Get recently played videos - Returns VideoModel for quality access
  Future<List<VideoModel>> getRecentlyPlayedVideos();
}
