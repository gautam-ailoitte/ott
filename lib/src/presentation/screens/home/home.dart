// lib/src/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/navigations/app_router.dart';
import '../../../core/navigations/navigation_arguments.dart';
import '../../cubits/home_cubit/home_cubit.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/carousel_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/safe_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HomeCubit>()..loadHomeData(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return _buildLoadingView();
              } else if (state is HomeLoaded) {
                return _buildLoadedView(context, state);
              } else if (state is HomeError) {
                return _buildErrorView(context, state.message);
              } else if (state is HomeEmpty) {
                return _buildEmptyView();
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppDimensions.spaceL),
          SizedBox(height: 300, child: CarouselShimmer(itemCount: 1)),
          SizedBox(height: AppDimensions.spaceL),
          CarouselShimmer(isPortrait: false, itemCount: 4),
          SizedBox(height: AppDimensions.spaceL),
          CarouselShimmer(isPortrait: true, itemCount: 3),
        ],
      ),
    );
  }

  Widget _buildLoadedView(BuildContext context, HomeLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeCubit>().refreshHomeData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            _buildAppHeader(),

            // Featured Content
            if (state.homeData.featuredContent != null)
              _buildFeaturedContent(context, state.homeData.featuredContent!),

            // Video Carousels
            if (state.homeData.carousels?.isNotEmpty == true)
              ...state.homeData.carousels!.map(
                (carousel) => _buildVideoCarousel(context, carousel),
              ),

            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spaceM),
          Text(
            AppStrings.appTitle,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedContent(BuildContext context, featuredContent) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            child: SafeImage(
              imageUrl:
                  featuredContent.backdropUrl ?? featuredContent.thumbnailUrl,
              width: double.infinity,
              height: 400,
              fit: BoxFit.cover,
            ),
          ),

          // Gradient Overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            bottom: AppDimensions.spaceL,
            left: AppDimensions.spaceL,
            right: AppDimensions.spaceL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  featuredContent.title ?? 'Featured Content',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceS),
                if (featuredContent.description != null)
                  Text(
                    featuredContent.description!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppDimensions.spaceL),
                Row(
                  children: [
                    AppButton(
                      text: AppStrings.play,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () =>
                          _playFeaturedContent(context, featuredContent),
                      type: AppButtonType.primary,
                    ),
                    const SizedBox(width: AppDimensions.spaceM),
                    AppButton(
                      text: 'More Info',
                      icon: Icons.info_outline,
                      onPressed: () {
                        // Could navigate to details screen
                      },
                      type: AppButtonType.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCarousel(BuildContext context, carousel) {
    if (carousel.videos?.isEmpty == true) {
      return const SizedBox.shrink();
    }

    final isPortrait = carousel.thumbnailStyle == 'portrait';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel Title
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carousel.title ?? 'Videos',
                  style: AppTextStyles.carouselTitle,
                ),
                if (carousel.subtitle != null) ...[
                  const SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    carousel.subtitle!,
                    style: AppTextStyles.carouselSubtitle,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spaceM),

          // Video List
          SizedBox(
            height: isPortrait
                ? AppDimensions.thumbnailPortraitHeight
                : AppDimensions.thumbnailLandscapeHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spaceM,
              ),
              itemCount: carousel.videos!.length,
              itemBuilder: (context, index) {
                final video = carousel.videos![index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < carousel.videos!.length - 1
                        ? AppDimensions.carouselItemSpacing
                        : 0,
                  ),
                  child: _buildVideoThumbnail(
                    context,
                    video,
                    isPortrait,
                    carousel.showProgressBar == true,
                    carousel.videos!,
                    index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(
    BuildContext context,
    video,
    bool isPortrait,
    bool showProgressBar,
    List<dynamic> playlist,
    int currentIndex,
  ) {
    final thumbnailWidth = isPortrait
        ? AppDimensions.thumbnailPortraitWidth
        : AppDimensions.thumbnailLandscapeWidth;
    final thumbnailHeight = isPortrait
        ? AppDimensions.thumbnailPortraitHeight
        : AppDimensions.thumbnailLandscapeHeight;

    return GestureDetector(
      onTap: () => _playVideo(context, video, playlist, currentIndex),
      child: SizedBox(
        width: thumbnailWidth,
        height: thumbnailHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail - Fixed height
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    child: SafeImage(
                      imageUrl: video.thumbnailUrl,
                      width: thumbnailWidth,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Play Button Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppColors.textPrimary,
                        size: 48,
                      ),
                    ),
                  ),

                  // Progress Bar (if applicable)
                  if (showProgressBar &&
                      video.progressData?.progressPercentage != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: AppDimensions.progressBarHeight,
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spaceXS,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.progressBarRadius,
                          ),
                          child: LinearProgressIndicator(
                            value:
                                (video.progressData!.progressPercentage! / 100)
                                    .clamp(0.0, 1.0),
                            backgroundColor: AppColors.progressBackground,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.progressForeground,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Video Title - Constrained height
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: AppDimensions.spaceS),
                child: Text(
                  video.title ?? 'Untitled',
                  style: AppTextStyles.videoTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return AppErrorWidget(
      message: message,
      onRetry: () {
        context.read<HomeCubit>().loadHomeData();
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.movie_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppDimensions.spaceL),
          Text(AppStrings.noVideosFound, style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.spaceS),
          Text(
            'Check back later for new content',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Fixed: Use HomeCubit conversion methods for type safety
  void _playFeaturedContent(BuildContext context, featuredContent) async {
    final cubit = context.read<HomeCubit>();

    // Get VideoModel for player
    final videoModel = await cubit.getVideoForPlayer(featuredContent.id!);
    if (videoModel != null) {
      Navigator.of(context).pushNamed(
        AppRouter.videoPlayer,
        arguments: VideoPlayerArguments(video: videoModel),
      );
    }
  }

  void _playVideo(
    BuildContext context,
    video,
    List<dynamic> playlist,
    int currentIndex,
  ) async {
    final cubit = context.read<HomeCubit>();

    // Convert entities to models for player
    final videoModels = await cubit.convertVideosForPlayer(
      playlist.cast(), // Convert to List<VideoEntity>
    );

    if (videoModels.isNotEmpty) {
      final safeIndex = currentIndex.clamp(0, videoModels.length - 1);
      Navigator.of(context).pushNamed(
        AppRouter.videoPlayer,
        arguments: VideoPlayerArguments(
          video: videoModels[safeIndex],
          playlist: videoModels,
          currentIndex: safeIndex,
        ),
      );
    }
  }
}
