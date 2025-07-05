// lib/src/presentation/cubits/home_cubit/home_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/video_model.dart';
import '../../../domain/entities/home_data_entity.dart';
import '../../../domain/entities/user_progress_entity.dart';
import '../../../domain/entities/video_entity.dart';
import '../../../domain/repositories/video_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final VideoRepository _videoRepository;

  HomeCubit(this._videoRepository) : super(HomeInitial());

  /// Load home screen data
  Future<void> loadHomeData() async {
    if (state is HomeLoading) return; // Prevent multiple calls

    emit(HomeLoading());

    try {
      final homeData = await _videoRepository.getHomeData();

      if (homeData.carousels?.isNotEmpty == true ||
          homeData.featuredContent != null) {
        emit(HomeLoaded(homeData));
      } else {
        emit(HomeEmpty());
      }
    } catch (error) {
      emit(HomeError(error.toString()));
    }
  }

  /// Refresh home data
  Future<void> refreshHomeData() async {
    emit(HomeLoading());
    await loadHomeData();
  }

  /// Load videos for specific category - Returns VideoModel for Better Player
  Future<void> loadCategoryVideos(String categoryId) async {
    try {
      final videos = await _videoRepository.getVideosByCategory(categoryId);

      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(
          HomeLoaded(
            currentState.homeData,
            categoryVideos: {
              ...currentState.categoryVideos,
              categoryId: videos,
            },
          ),
        );
      }
    } catch (error) {
      // Silent fail for category loading, don't break main UI
      debugPrint('Failed to load category videos: $error');
    }
  }

  /// Load recently played videos with full VideoModel data
  Future<void> loadRecentlyPlayedVideos() async {
    try {
      final recentVideos = await _videoRepository.getRecentlyPlayedVideos();

      if (state is HomeLoaded) {
        final currentState = state as HomeLoaded;
        emit(
          HomeLoaded(
            currentState.homeData,
            categoryVideos: currentState.categoryVideos,
            recentlyPlayedVideos: recentVideos,
          ),
        );
      }
    } catch (error) {
      // Silent fail for recently played
      debugPrint('Failed to load recently played videos: $error');
    }
  }

  /// Update video progress (when user watches a video)
  Future<void> updateVideoProgress(
    String videoId,
    int currentPosition,
    int totalDuration,
  ) async {
    try {
      final progressPercentage = (currentPosition / totalDuration) * 100;

      final progressEntity = UserProgressEntity(
        videoId: videoId,
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        progressPercentage: progressPercentage,
        lastWatched: DateTime.now().toIso8601String(),
      );
      await _videoRepository.updateVideoProgress(videoId, progressEntity);

      // Reload recently played to reflect changes
      await loadRecentlyPlayedVideos();
    } catch (error) {
      // Silent fail for progress update
      debugPrint('Failed to update video progress: $error');
    }
  }

  /// Get video by ID with full VideoModel data for player
  Future<VideoModel?> getVideoForPlayer(String videoId) async {
    try {
      return await _videoRepository.getVideoById(videoId);
    } catch (error) {
      debugPrint('Failed to get video for player: $error');
      return null;
    }
  }

  /// Get playlist videos for reels-style navigation
  Future<List<VideoModel>> getPlaylistVideos(String playlistId) async {
    try {
      return await _videoRepository.getPlaylistVideos(playlistId);
    } catch (error) {
      debugPrint('Failed to get playlist videos: $error');
      return [];
    }
  }

  /// ✅ NEW: Convert VideoEntity list to VideoModel list for navigation
  Future<List<VideoModel>> convertVideosForPlayer(
    List<VideoEntity> videoEntities,
  ) async {
    final List<VideoModel> videoModels = [];

    for (final entity in videoEntities) {
      if (entity.id != null) {
        try {
          final videoModel = await _videoRepository.getVideoById(entity.id!);
          if (videoModel != null) {
            videoModels.add(videoModel);
          }
        } catch (e) {
          debugPrint('Failed to convert video ${entity.id}: $e');
          // Continue with other videos instead of failing completely
        }
      }
    }

    return videoModels;
  }

  /// ✅ NEW: Get videos from specific carousel for playlist navigation
  Future<List<VideoModel>> getCarouselVideosForPlayer(String carouselId) async {
    try {
      if (state is HomeLoaded) {
        final homeData = (state as HomeLoaded).homeData;
        final carousel = homeData.carousels?.firstWhere(
          (c) => c.id == carouselId,
          orElse: () => throw Exception('Carousel not found'),
        );

        if (carousel?.videos != null) {
          return await convertVideosForPlayer(carousel!.videos!);
        }
      }
      return [];
    } catch (error) {
      debugPrint('Failed to get carousel videos for player: $error');
      return [];
    }
  }

  /// ✅ NEW: Enhanced method to get video with context (includes related videos)
  Future<Map<String, dynamic>> getVideoWithContext(String videoId) async {
    try {
      final videoModel = await getVideoForPlayer(videoId);
      if (videoModel == null) {
        return {'video': null, 'playlist': <VideoModel>[]};
      }

      // Try to find related videos from the same category/carousel
      List<VideoModel> relatedVideos = [];

      if (state is HomeLoaded) {
        final homeData = (state as HomeLoaded).homeData;

        // Find the carousel containing this video
        for (final carousel in homeData.carousels ?? <dynamic>[]) {
          final containsVideo =
              carousel.videos?.any((v) => v.id == videoId) == true;
          if (containsVideo && carousel.videos != null) {
            relatedVideos = await convertVideosForPlayer(carousel.videos!);
            break;
          }
        }
      }

      return {'video': videoModel, 'playlist': relatedVideos};
    } catch (error) {
      debugPrint('Failed to get video with context: $error');
      return {'video': null, 'playlist': <VideoModel>[]};
    }
  }

  /// Reset to initial state
  void reset() {
    emit(HomeInitial());
  }
}
