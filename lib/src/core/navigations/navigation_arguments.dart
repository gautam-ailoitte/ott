import '../../domain/entities/video_entity.dart';

class VideoPlayerArguments {
  final VideoEntity video;
  final List<VideoEntity>? playlist;
  final int? currentIndex;
  final String? playlistContext;

  const VideoPlayerArguments({
    required this.video,
    this.playlist,
    this.currentIndex,
    this.playlistContext,
  });
}
