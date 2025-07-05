import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// Load videos for specific category
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

  /// Load recently played videos
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

  /// Reset to initial state
  void reset() {
    emit(HomeInitial());
  }
}
