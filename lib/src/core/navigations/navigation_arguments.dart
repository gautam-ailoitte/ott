// lib/src/core/navigations/navigation_arguments.dart
import '../../data/models/video_model.dart';

class VideoPlayerArguments {
  final VideoModel video;
  final List<VideoModel>? playlist;
  final int? currentIndex;
  final String? playlistContext;

  const VideoPlayerArguments({
    required this.video,
    this.playlist,
    this.currentIndex,
    this.playlistContext,
  });

  /// Helper to get safe playlist for player
  List<VideoModel> get safePlaylist {
    if (playlist?.isNotEmpty == true) {
      return playlist!;
    }
    return [video];
  }

  /// Helper to get safe initial index
  int get safeInitialIndex {
    if (playlist?.isNotEmpty == true && currentIndex != null) {
      return currentIndex!.clamp(0, playlist!.length - 1);
    }
    return 0;
  }
}
