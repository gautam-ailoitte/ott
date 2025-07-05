import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_progress_entity.dart';
import '../../../domain/entities/video_catalog_entity.dart';
import '../../../domain/entities/video_entity.dart';
import '../../../domain/repositories/video_repository.dart';

part 'video_player_state.dart';

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  final VideoRepository _videoRepository;

  VideoPlayerCubit(this._videoRepository) : super(VideoPlayerInitial());

  /// Initialize video player with a video and optional playlist
  Future<void> initializePlayer({
    required VideoEntity video,
    List<VideoEntity>? playlist,
    int? currentIndex,
    String? playlistContext,
  }) async {
    emit(VideoPlayerLoading());

    try {
      // Get video catalog for navigation
      final videoCatalog = await _videoRepository.getVideoCatalogById(
        video.id ?? '',
      );

      // If playlist not provided, try to get from playlist context
      List<VideoEntity> videoPlaylist = playlist ?? [];
      int videoIndex = currentIndex ?? 0;

      if (playlist == null && videoCatalog?.playlistContext != null) {
        videoPlaylist = await _videoRepository.getPlaylistVideos(
          videoCatalog!.playlistContext!,
        );
        videoIndex = videoPlaylist.indexWhere((v) => v.id == video.id);
        if (videoIndex == -1) videoIndex = 0;
      }

      emit(
        VideoPlayerReady(
          currentVideo: video,
          playlist: videoPlaylist,
          currentIndex: videoIndex,
          videoCatalog: videoCatalog,
          playlistContext: playlistContext ?? videoCatalog?.playlistContext,
        ),
      );
    } catch (error) {
      emit(VideoPlayerError(error.toString()));
    }
  }

  /// Play specific video
  void playVideo(VideoEntity video) {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;

      // Find video in current playlist
      int newIndex = currentState.playlist.indexWhere((v) => v.id == video.id);
      if (newIndex == -1) {
        // Video not in current playlist, play as single video
        emit(
          VideoPlayerReady(
            currentVideo: video,
            playlist: [video],
            currentIndex: 0,
            videoCatalog: currentState.videoCatalog,
            playlistContext: currentState.playlistContext,
          ),
        );
      } else {
        // Video found in playlist
        emit(
          VideoPlayerReady(
            currentVideo: video,
            playlist: currentState.playlist,
            currentIndex: newIndex,
            videoCatalog: currentState.videoCatalog,
            playlistContext: currentState.playlistContext,
          ),
        );
      }
    }
  }

  /// Navigate to next video
  Future<void> nextVideo() async {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;

      if (currentState.hasNextVideo) {
        final nextIndex = currentState.currentIndex + 1;
        final nextVideo = currentState.playlist[nextIndex];

        emit(
          VideoPlayerReady(
            currentVideo: nextVideo,
            playlist: currentState.playlist,
            currentIndex: nextIndex,
            videoCatalog: currentState.videoCatalog,
            playlistContext: currentState.playlistContext,
          ),
        );

        // Update video progress for analytics
        await _updateVideoProgress(nextVideo);
      }
    }
  }

  /// Navigate to previous video
  Future<void> previousVideo() async {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;

      if (currentState.hasPreviousVideo) {
        final previousIndex = currentState.currentIndex - 1;
        final previousVideo = currentState.playlist[previousIndex];

        emit(
          VideoPlayerReady(
            currentVideo: previousVideo,
            playlist: currentState.playlist,
            currentIndex: previousIndex,
            videoCatalog: currentState.videoCatalog,
            playlistContext: currentState.playlistContext,
          ),
        );

        // Update video progress for analytics
        await _updateVideoProgress(previousVideo);
      }
    }
  }

  /// Update video progress
  Future<void> updateProgress({
    required String videoId,
    required int currentPosition,
    required int totalDuration,
  }) async {
    try {
      final progressPercentage = (currentPosition / totalDuration * 100).clamp(
        0.0,
        100.0,
      );

      // Create user progress entity and update
      final progressEntity = UserProgressEntity(
        videoId: videoId,
        lastWatched: DateTime.now().toIso8601String(),
        currentPosition: currentPosition,
        totalDuration: totalDuration,
        progressPercentage: progressPercentage,
        watchStatus: 'in_progress',
        watchCount: 1, // todo: Increment logic can be added later
        firstWatched: DateTime.now().toIso8601String(),
      );
      await _videoRepository.updateVideoProgress(videoId, progressEntity);

      // Emit progress update state if needed
      if (state is VideoPlayerReady) {
        final currentState = state as VideoPlayerReady;
        emit(
          VideoPlayerProgressUpdated(
            currentState.currentVideo,
            currentPosition,
            totalDuration,
            progressPercentage,
          ),
        );

        // Return to ready state
        emit(currentState);
      }
    } catch (error) {
      // Silent fail for progress updates
    }
  }

  /// Handle video completion
  Future<void> onVideoCompleted() async {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;

      // Mark as completed and auto-play next if available
      await updateProgress(
        videoId: currentState.currentVideo.id ?? '',
        currentPosition: currentState.currentVideo.duration ?? 0,
        totalDuration: currentState.currentVideo.duration ?? 0,
      );

      // Auto-play next video if available
      if (currentState.hasNextVideo) {
        await nextVideo();
      }
    }
  }

  /// Pause video playback
  void pauseVideo() {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      emit(VideoPlayerPaused(currentState));
    }
  }

  /// Resume video playback
  void resumeVideo() {
    if (state is VideoPlayerPaused) {
      final pausedState = state as VideoPlayerPaused;
      emit(pausedState.previousState);
    }
  }

  /// Stop video and reset
  void stopVideo() {
    emit(VideoPlayerStopped());
  }

  /// Dispose player
  void disposePlayer() {
    emit(VideoPlayerInitial());
  }

  /// Private helper to update video progress
  Future<void> _updateVideoProgress(VideoEntity video) async {
    try {
      // Create progress tracking entry
      // This will be useful for analytics and resume functionality
      final progressEntity = UserProgressEntity(
        videoId: video.id ?? '',
        lastWatched: DateTime.now().toIso8601String(),
        currentPosition: 0, // Reset position for new video
        totalDuration: video.duration ?? 0,
        progressPercentage: 0.0,
        watchStatus: 'in_progress',
        watchCount: 1, // Increment logic can be added later
        firstWatched: DateTime.now().toIso8601String(),
      );
      await _videoRepository.updateVideoProgress(
        video.id ?? '',
        progressEntity,
      );
    } catch (error) {
      // Silent fail
    }
  }
}
