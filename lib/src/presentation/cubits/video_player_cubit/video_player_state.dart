part of 'video_player_cubit.dart';

abstract class VideoPlayerState {}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerLoading extends VideoPlayerState {}

class VideoPlayerReady extends VideoPlayerState {
  final VideoEntity currentVideo;
  final List<VideoEntity> playlist;
  final int currentIndex;
  final VideoCatalogEntity? videoCatalog;
  final String? playlistContext;

  VideoPlayerReady({
    required this.currentVideo,
    required this.playlist,
    required this.currentIndex,
    this.videoCatalog,
    this.playlistContext,
  });

  bool get hasNextVideo => currentIndex < playlist.length - 1;
  bool get hasPreviousVideo => currentIndex > 0;

  VideoEntity? get nextVideo =>
      hasNextVideo ? playlist[currentIndex + 1] : null;
  VideoEntity? get previousVideo =>
      hasPreviousVideo ? playlist[currentIndex - 1] : null;
}

class VideoPlayerPaused extends VideoPlayerState {
  final VideoPlayerReady previousState;

  VideoPlayerPaused(this.previousState);
}

class VideoPlayerStopped extends VideoPlayerState {}

class VideoPlayerProgressUpdated extends VideoPlayerState {
  final VideoEntity video;
  final int currentPosition;
  final int totalDuration;
  final double progressPercentage;

  VideoPlayerProgressUpdated(
    this.video,
    this.currentPosition,
    this.totalDuration,
    this.progressPercentage,
  );
}

class VideoPlayerError extends VideoPlayerState {
  final String message;

  VideoPlayerError(this.message);
}
