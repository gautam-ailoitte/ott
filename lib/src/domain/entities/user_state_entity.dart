import 'package:ott/src/domain/entities/user_progress_entity.dart';

class UserStateEntity {
  final String? lastUpdated;
  final List<UserProgressEntity>? videos;

  const UserStateEntity({this.lastUpdated, this.videos});
}

// lib/domain/entities/navigation_playlist_entity.dart
class NavigationPlaylistEntity {
  final String? playlistId;
  final List<String>? videoIds;

  const NavigationPlaylistEntity({this.playlistId, this.videoIds});
}
