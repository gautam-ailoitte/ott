import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class ProgressBarWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double? height;
  final Color? backgroundColor;
  final Color? progressColor;
  final BorderRadius? borderRadius;

  const ProgressBarWidget({
    super.key,
    required this.progress,
    this.height,
    this.backgroundColor,
    this.progressColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? AppDimensions.progressBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.progressBackground,
        borderRadius:
            borderRadius ??
            BorderRadius.circular(AppDimensions.progressBarRadius),
      ),
      child: ClipRRect(
        borderRadius:
            borderRadius ??
            BorderRadius.circular(AppDimensions.progressBarRadius),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            progressColor ?? AppColors.progressForeground,
          ),
        ),
      ),
    );
  }
}
