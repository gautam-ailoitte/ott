// lib/src/presentation/screens/home/widgets/video_thumbnail.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/carousel_entity.dart';


class VideoThumbnail extends StatelessWidget {
  final VideoEntity video;
  final List<VideoEntity>? playlist;
  final int? currentIndex;
  final double? width;
  final double? height;

  const VideoThumbnail({
    super.key,
    required this.video,
    this.playlist,
    this.currentIndex,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onVideoTap(context),
      child: Container(
        width: width ?? ,
        height: height ?? AppDimensions.carouselItemHeight,
        margin: const EdgeInsets.only(right: AppDimensions.spacingS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          color: AppColors.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail Image
              SafeImage(
                imageUrl: video.thumbnailUrl,
                fit: BoxFit.cover,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              // Play Icon
              const Center(
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white,
                  size: 48,
                ),
              ),

              // Video Info
              Positioned(
                bottom: AppDimensions.spacingXS,
                left: AppDimensions.spacingXS,
                right: AppDimensions.spacingXS,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (video.title?.isNotEmpty == true)
                      Text(
                        video.title!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (video.duration != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDuration(video.duration!),
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ Type-safe navigation with proper VideoEntity to VideoModel conversion
  Future<void> _onVideoTap(BuildContext context) async {
    final cubit = context.read<HomeCubit>();

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convert current video to VideoModel
      final VideoModel? videoModel = await cubit.getVideoForPlayer(video.id!);

      if (videoModel == null) {
        Navigator.pop(context); // Remove loading dialog
        _showErrorDialog(context, 'Video not available');
        return;
      }

      // Convert playlist entities to models if playlist exists
      List<VideoModel>? playlistModels;
      if (playlist?.isNotEmpty == true) {
        playlistModels = [];

        for (final entity in playlist!) {
          if (entity.id != null) {
            final model = await cubit.getVideoForPlayer(entity.id!);
            if (model != null) {
              playlistModels.add(model);
            }
          }
        }

        // If no valid models found, fall back to single video
        if (playlistModels.isEmpty) {
          playlistModels = null;
        }
      }

      Navigator.pop(context); // Remove loading dialog

      // Navigate to video player with VideoModel
      Navigator.pushNamed(
        context,
        AppRouter.videoPlayer,
        arguments: VideoPlayerArguments(
          video: videoModel,
          playlist: playlistModels,
          currentIndex: currentIndex ?? 0,
          playlistContext: playlist != null ? 'carousel' : 'single',
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Remove loading dialog if still showing
      _showErrorDialog(context, 'Failed to load video: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

// lib/src/presentation/screens/home/widgets/video_carousel.dart


class VideoCarousel extends StatelessWidget {
  final CarouselEntity carousel;

  const VideoCarousel({
    super.key,
    required this.carousel,
  });

  @override
  Widget build(BuildContext context) {
    if (carousel.videos?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carousel Title
        if (carousel.title?.isNotEmpty == true)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
            ),
            child: Text(
              carousel.title!,
              style: AppTextStyles.headlineSmall,
            ),
          ),

        SizedBox(height: AppDimensions.spacingS),

        // Videos List
        SizedBox(
          height: AppDimensions.carouselItemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
            ),
            itemCount: carousel.videos!.length,
            itemBuilder: (context, index) {
              final video = carousel.videos![index];

              return VideoThumbnail(
                video: video,
                playlist: carousel.videos, // ✅ Pass entire carousel as playlist
                currentIndex: index,       // ✅ Pass current index
              );
            },
          ),
        ),

        SizedBox(height: AppDimensions.spacingL),
      ],
    );
  }
}