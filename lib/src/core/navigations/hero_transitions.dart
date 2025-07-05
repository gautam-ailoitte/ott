import 'package:flutter/material.dart';

class HeroTransitions {
  /// Create hero widget for video thumbnail to player transition
  static Widget videoThumbnailHero({
    required String videoId,
    required Widget child,
  }) {
    return Hero(tag: 'video_thumbnail_$videoId', child: child);
  }

  /// Create hero widget for video player
  static Widget videoPlayerHero({
    required String videoId,
    required Widget child,
  }) {
    return Hero(tag: 'video_thumbnail_$videoId', child: child);
  }

  /// Shared element transition for video cards
  static Widget sharedVideoCard({
    required String videoId,
    required Widget child,
  }) {
    return Hero(
      tag: 'video_card_$videoId',
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}
