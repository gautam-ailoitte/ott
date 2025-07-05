import '../../domain/entities/home_data_entity.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/entities/video_catalog_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/mock_video_datasource.dart';
import '../datasources/user_datasource.dart';
import '../models/home_data_model.dart';
import '../models/progress_data_model.dart';
import '../models/user_progress_model.dart';
import '../models/user_state_model.dart';
import '../models/video_catalog_model.dart';
import '../models/video_model.dart';

class VideoRepositoryImpl implements VideoRepository {
  final MockVideoDataSource _mockDataSource;
  final UserDataSource _userDataSource;

  VideoRepositoryImpl(this._mockDataSource, this._userDataSource);

  @override
  Future<HomeDataEntity> getHomeData() async {
    try {
      final jsonData = await _mockDataSource.loadMockData();

      // Initialize user state from JSON if not already set
      if (_userDataSource.getUserState() == null &&
          jsonData['user_state'] != null) {
        final userStateData = jsonData['user_state']['recently_played'];
        if (userStateData != null) {
          final userState = UserStateModel.fromJson(
            userStateData as Map<String, dynamic>,
          );
          _userDataSource.updateUserState(userState);
        }
      }

      return HomeDataModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load home data: $e');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      final jsonData = await _mockDataSource.loadMockData();
      final carousels = jsonData['carousels'] as List<dynamic>;

      for (final carouselData in carousels) {
        final carousel = carouselData as Map<String, dynamic>;
        if (carousel['id'] == category) {
          final videos = carousel['videos'] as List<dynamic>;
          return videos
              .map(
                (video) => VideoModel.fromJson(video as Map<String, dynamic>),
              )
              .toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load videos for category $category: $e');
    }
  }

  @override
  Future<VideoModel?> getVideoById(String id) async {
    try {
      final jsonData = await _mockDataSource.loadMockData();

      // Search in carousels
      final carousels = jsonData['carousels'] as List<dynamic>;
      for (final carouselData in carousels) {
        final carousel = carouselData as Map<String, dynamic>;
        final videos = carousel['videos'] as List<dynamic>;

        for (final videoData in videos) {
          final video = videoData as Map<String, dynamic>;
          if (video['id'] == id) {
            return VideoModel.fromJson(video);
          }
        }
      }

      // Search in featured content
      final featuredContent =
          jsonData['featured_content'] as Map<String, dynamic>?;
      if (featuredContent?['id'] == id) {
        // Convert featured content to video format
        final videoData = {
          'id': featuredContent!['id'],
          'title': featuredContent['title'],
          'description': featuredContent['description'],
          'thumbnail_url': featuredContent['thumbnail_url'],
          'duration': featuredContent['duration'],
          'category': featuredContent['category'],
          'rating': featuredContent['rating'],
          'release_year': featuredContent['release_year'],
          'content_type': featuredContent['content_type'],
          // Handle both old and new video sources format
          if (featuredContent['video_sources'] != null)
            'video_sources': featuredContent['video_sources']
          else if (featuredContent['video_url'] != null)
            'video_url': featuredContent['video_url'],
        };

        return VideoModel.fromJson(videoData);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to load video $id: $e');
    }
  }

  @override
  Future<VideoCatalogEntity?> getVideoCatalogById(String id) async {
    try {
      final jsonData = await _mockDataSource.loadMockData();
      final videoCatalog = jsonData['video_catalog'] as Map<String, dynamic>;

      if (videoCatalog.containsKey(id)) {
        return VideoCatalogModel.fromJson(
          videoCatalog[id] as Map<String, dynamic>,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Failed to load video catalog for $id: $e');
    }
  }

  @override
  Future<List<VideoModel>> getPlaylistVideos(String playlistId) async {
    try {
      final jsonData = await _mockDataSource.loadMockData();
      final playlists =
          jsonData['navigation_playlists'] as Map<String, dynamic>;

      if (!playlists.containsKey(playlistId)) {
        return [];
      }

      final videoIds = List<String>.from(
        playlists[playlistId] as List<dynamic>,
      );
      final videos = <VideoModel>[];

      for (final videoId in videoIds) {
        final video = await getVideoById(videoId);
        if (video != null) {
          videos.add(video);
        }
      }

      return videos;
    } catch (e) {
      throw Exception('Failed to load playlist $playlistId: $e');
    }
  }

  @override
  Future<Map<String, List<String>>> getNavigationPlaylists() async {
    try {
      final jsonData = await _mockDataSource.loadMockData();
      final playlists =
          jsonData['navigation_playlists'] as Map<String, dynamic>;

      return playlists.map(
        (key, value) =>
            MapEntry(key, List<String>.from(value as List<dynamic>)),
      );
    } catch (e) {
      throw Exception('Failed to load navigation playlists: $e');
    }
  }

  @override
  Future<void> updateVideoProgress(
    String videoId,
    UserProgressEntity progress,
  ) async {
    try {
      _userDataSource.updateVideoProgress(
        videoId,
        progress as UserProgressModel,
      );
    } catch (e) {
      throw Exception('Failed to update video progress: $e');
    }
  }

  @override
  Future<List<UserProgressEntity>> getUserProgress() async {
    try {
      final userState = _userDataSource.getUserState();
      return userState?.videos ?? [];
    } catch (e) {
      throw Exception('Failed to get user progress: $e');
    }
  }

  @override
  Future<List<VideoModel>> getRecentlyPlayedVideos() async {
    try {
      final videoIds = _userDataSource.getContinueWatchingVideoIds();
      final videos = <VideoModel>[];

      for (final videoId in videoIds) {
        final video = await getVideoById(videoId);
        if (video != null) {
          // Add progress data to the video
          final progress = _userDataSource.getVideoProgress(videoId);
          if (progress != null) {
            // Convert UserProgressModel to ProgressDataModel
            final progressData = ProgressDataModel(
              currentPosition: progress.currentPosition,
              progressPercentage: progress.progressPercentage,
              lastWatched: progress.lastWatched,
            );

            // Create VideoModel with progress data
            final videoWithProgress = VideoModel(
              id: video.id,
              title: video.title,
              description: video.description,
              thumbnailUrl: video.thumbnailUrl,
              videoUrl: video.videoUrl,
              duration: video.duration,
              category: video.category,
              rating: video.rating,
              releaseYear: video.releaseYear,
              contentType: video.contentType,
              thumbnailAspectRatio: video.thumbnailAspectRatio,
              progressData: progressData,
              // 🎯 IMPORTANT: Preserve video sources for Better Player
              videoSources: video.videoSources,
            );

            videos.add(videoWithProgress);
          } else {
            videos.add(video);
          }
        }
      }

      return videos;
    } catch (e) {
      throw Exception('Failed to load recently played videos: $e');
    }
  }

  // 🎯 NEW: Additional helper methods for Better Player integration

  /// Get all videos from all carousels for reels-style navigation
  Future<List<VideoModel>> getAllVideos() async {
    try {
      final jsonData = await _mockDataSource.loadMockData();
      final carousels = jsonData['carousels'] as List<dynamic>;
      final allVideos = <VideoModel>[];

      for (final carouselData in carousels) {
        final carousel = carouselData as Map<String, dynamic>;
        final videos = carousel['videos'] as List<dynamic>;

        final carouselVideos = videos
            .map((video) => VideoModel.fromJson(video as Map<String, dynamic>))
            .toList();

        allVideos.addAll(carouselVideos);
      }

      // Also add featured content if it exists
      final featuredContent =
          jsonData['featured_content'] as Map<String, dynamic>?;
      if (featuredContent != null) {
        final featuredVideo = VideoModel.fromJson({
          'id': featuredContent['id'],
          'title': featuredContent['title'],
          'description': featuredContent['description'],
          'thumbnail_url': featuredContent['thumbnail_url'],
          'duration': featuredContent['duration'],
          'category': featuredContent['category'],
          'rating': featuredContent['rating'],
          'release_year': featuredContent['release_year'],
          'content_type': featuredContent['content_type'],
          if (featuredContent['video_sources'] != null)
            'video_sources': featuredContent['video_sources']
          else if (featuredContent['video_url'] != null)
            'video_url': featuredContent['video_url'],
        });

        // Add featured content at the beginning
        allVideos.insert(0, featuredVideo);
      }

      return allVideos;
    } catch (e) {
      throw Exception('Failed to load all videos: $e');
    }
  }

  /// Get videos for a specific category with Better Player optimization
  Future<List<VideoModel>> getCategoryVideosOptimized(String categoryId) async {
    try {
      final videos = await getVideosByCategory(categoryId);

      // Sort by priority or rating for better user experience
      videos.sort((a, b) {
        final ratingA = a.rating ?? 0.0;
        final ratingB = b.rating ?? 0.0;
        return ratingB.compareTo(ratingA); // Highest rating first
      });

      return videos;
    } catch (e) {
      throw Exception('Failed to load optimized category videos: $e');
    }
  }

  /// Get video with progress data for continue watching
  Future<VideoModel?> getVideoWithProgress(String videoId) async {
    try {
      final video = await getVideoById(videoId);
      if (video == null) return null;

      final progress = _userDataSource.getVideoProgress(videoId);
      if (progress == null) return video;

      // Return video with progress data
      return VideoModel(
        id: video.id,
        title: video.title,
        description: video.description,
        thumbnailUrl: video.thumbnailUrl,
        videoUrl: video.videoUrl,
        duration: video.duration,
        category: video.category,
        rating: video.rating,
        releaseYear: video.releaseYear,
        contentType: video.contentType,
        thumbnailAspectRatio: video.thumbnailAspectRatio,
        videoSources: video.videoSources,
        progressData: ProgressDataModel(
          currentPosition: progress.currentPosition,
          progressPercentage: progress.progressPercentage,
          lastWatched: progress.lastWatched,
        ),
      );
    } catch (e) {
      throw Exception('Failed to load video with progress: $e');
    }
  }
}
