import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../common/shimmer_widget.dart';
import 'thumbnail_shimmer.dart';

class CarouselShimmer extends StatelessWidget {
  final bool isPortrait;
  final int itemCount;

  const CarouselShimmer({
    super.key,
    this.isPortrait = false,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          child: ShimmerWidget(
            child: Container(
              width: 200,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceS),

        // Subtitle shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceM),
          child: ShimmerWidget(
            child: Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.shimmerBase,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceM),

        // Thumbnails shimmer
        SizedBox(
          height: isPortrait
              ? AppDimensions.thumbnailPortraitHeight
              : AppDimensions.thumbnailLandscapeHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceM,
            ),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < itemCount - 1
                      ? AppDimensions.carouselItemSpacing
                      : 0,
                ),
                child: ThumbnailShimmer(isPortrait: isPortrait),
              );
            },
          ),
        ),
      ],
    );
  }
}
