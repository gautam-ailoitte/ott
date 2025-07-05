class ProgressDataEntity {
  final int? currentPosition; // in seconds
  final double? progressPercentage;
  final String? lastWatched; // ISO string

  const ProgressDataEntity({
    this.currentPosition,
    this.progressPercentage,
    this.lastWatched,
  });
}
