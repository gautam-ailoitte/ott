import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../common/shimmer_widget.dart';

class ThumbnailShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final bool isPortrait;

  const ThumbnailShimmer({
    super.key,
    this.width,
    this.height,
    this.isPortrait = false,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailWidth =
        width ??
        (isPortrait
            ? AppDimensions.thumbnailPortraitWidth
            : AppDimensions.thumbnailLandscapeWidth);
    final thumbnailHeight =
        height ??
        (isPortrait
            ? AppDimensions.thumbnailPortraitHeight
            : AppDimensions.thumbnailLandscapeHeight);

    return ShimmerWidget(
      child: Container(
        width: thumbnailWidth,
        height: thumbnailHeight,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),
    );
  }
}
