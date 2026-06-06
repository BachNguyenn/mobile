import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class JlptLevelBadge extends StatelessWidget {
  final int level;
  final Color color;

  const JlptLevelBadge({
    super.key,
    required this.level,
    this.color = AppColors.zenBlue,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.20)),
      ),
      child: Text(
        'N$level',
        style: AppTypography.labelS.copyWith(
          color: resolvedColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
