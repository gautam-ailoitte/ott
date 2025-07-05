class VideoCatalogEntity {
  final String? id;
  final String? title;
  final String? videoUrl;
  final int? duration;
  final String? nextVideoId;
  final String? previousVideoId;
  final String? playlistContext;

  const VideoCatalogEntity({
    this.id,
    this.title,
    this.videoUrl,
    this.duration,
    this.nextVideoId,
    this.previousVideoId,
    this.playlistContext,
  });
}
