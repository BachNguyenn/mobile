import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Container mờ ảo kiểu Glassmorphism (kính mờ)
///
/// Sử dụng BackdropFilter + ClipRRect để tạo hiệu ứng blur
/// nền phía sau, kết hợp viền bán trong suốt.
///
/// ```dart
/// GlassmorphismContainer(
///   borderRadius: AppSpacing.radiusXL,
///   blur: 10,
///   child: Text('Search'),
/// )
/// ```
class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassmorphismContainer({
    super.key,
    required this.child,
    this.borderRadius = AppSpacing.radiusM,
    this.blur = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? AppSpacing.paddingAll16,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
