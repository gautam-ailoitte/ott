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
import '../../../domain/entities/carousel_entity.dart';
import '../../../domain/entities/featured_content_entity.dart';
import '../../../domain/entities/video_entity.dart';
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
      child: const _HomeScreenView(),
    );
  }
}

class _HomeScreenView extends StatelessWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const _HomeLoadingView();
            } else if (state is HomeLoaded) {
              return _HomeLoadedView(state: state);
            } else if (state is HomeError) {
              return _HomeErrorView(message: state.message);
            } else if (state is HomeEmpty) {
              return const _HomeEmptyView();
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: AppDimensions.spaceL),
          // Featured content shimmer
          SizedBox(height: 300, child: CarouselShimmer(itemCount: 1)),
          SizedBox(height: AppDimensions.spaceL),
          // Carousel shimmers
          CarouselShimmer(isPortrait: false, itemCount: 4),
          SizedBox(height: AppDimensions.spaceL),
          CarouselShimmer(isPortrait: true, itemCount: 3),
          SizedBox(height: AppDimensions.spaceL),
          CarouselShimmer(isPortrait: false, itemCount: 4),
        ],
      ),
    );
  }
}

class _HomeLoadedView extends StatelessWidget {
  final HomeLoaded state;

  const _HomeLoadedView({required this.state});

  @override
  Widget build(BuildContext context) {
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
            _buildAppHeader(context),

            // Featured Content
            if (state.homeData.featuredContent != null)
              _FeaturedContentSection(
                featuredContent: state.homeData.featuredContent!,
              ),

            // Video Carousels
            if (state.homeData.carousels?.isNotEmpty == true)
              ...state.homeData.carousels!.map(
                (carousel) => _VideoCarouselSection(carousel: carousel),
              ),

            // Bottom spacing
            const SizedBox(height: AppDimensions.spaceXXL),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceM),
      child: Row(
        children: [
          // App Logo/Title
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
          const Spacer(),
          // Profile/Search icons could go here
        ],
      ),
    );
  }
}

class _FeaturedContentSection extends StatelessWidget {
  final FeaturedContentEntity featuredContent;

  const _FeaturedContentSection({required this.featuredContent});

  @override
  Widget build(BuildContext context) {
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
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.9),
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
                      onPressed: () => _playFeaturedContent(context),
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

  void _playFeaturedContent(BuildContext context) {
    final video = VideoEntity(
      id: featuredContent.id,
      title: featuredContent.title,
      description: featuredContent.description,
      thumbnailUrl: featuredContent.thumbnailUrl,
      videoUrl: featuredContent.videoUrl,
      duration: featuredContent.duration,
      category: featuredContent.category,
      rating: featuredContent.rating,
      releaseYear: featuredContent.releaseYear,
      contentType: featuredContent.contentType,
    );

    Navigator.of(context).pushNamed(
      AppRouter.videoPlayer,
      arguments: VideoPlayerArguments(video: video),
    );
  }
}

class _VideoCarouselSection extends StatelessWidget {
  final CarouselEntity carousel;

  const _VideoCarouselSection({required this.carousel});

  @override
  Widget build(BuildContext context) {
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
                  child: _VideoThumbnailCard(
                    video: video,
                    isPortrait: isPortrait,
                    showProgressBar: carousel.showProgressBar == true,
                    playlist: carousel.videos!,
                    currentIndex: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnailCard extends StatelessWidget {
  final VideoEntity video;
  final bool isPortrait;
  final bool showProgressBar;
  final List<VideoEntity> playlist;
  final int currentIndex;

  const _VideoThumbnailCard({
    required this.video,
    required this.isPortrait,
    required this.showProgressBar,
    required this.playlist,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailWidth = isPortrait
        ? AppDimensions.thumbnailPortraitWidth
        : AppDimensions.thumbnailLandscapeWidth;
    final thumbnailHeight = isPortrait
        ? AppDimensions.thumbnailPortraitHeight
        : AppDimensions.thumbnailLandscapeHeight;

    return GestureDetector(
      onTap: () => _playVideo(context),
      child: SizedBox(
        width: thumbnailWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  child: SafeImage(
                    imageUrl: video.thumbnailUrl,
                    width: thumbnailWidth,
                    height: thumbnailHeight - 40, // Space for title
                    fit: BoxFit.cover,
                  ),
                ),

                // Play Button Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
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
                          value: (video.progressData!.progressPercentage! / 100)
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

            // Video Title
            const SizedBox(height: AppDimensions.spaceS),
            Text(
              video.title ?? 'Untitled',
              style: AppTextStyles.videoTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _playVideo(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRouter.videoPlayer,
      arguments: VideoPlayerArguments(
        video: video,
        playlist: playlist,
        currentIndex: currentIndex,
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  final String message;

  const _HomeErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: message,
      onRetry: () {
        context.read<HomeCubit>().loadHomeData();
      },
    );
  }
}

class _HomeEmptyView extends StatelessWidget {
  const _HomeEmptyView();

  @override
  Widget build(BuildContext context) {
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
}
