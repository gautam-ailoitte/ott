class UserProgressEntity {
  final String? videoId;
  final String? lastWatched;
  final int? currentPosition;
  final int? totalDuration;
  final double? progressPercentage;
  final String? watchStatus; // not_started, in_progress, completed
  final int? watchCount;
  final String? firstWatched;

  const UserProgressEntity({
    this.videoId,
    this.lastWatched,
    this.currentPosition,
    this.totalDuration,
    this.progressPercentage,
    this.watchStatus,
    this.watchCount,
    this.firstWatched,
  });
}
