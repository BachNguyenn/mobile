import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class CollapsedTitle extends StatelessWidget {
  const CollapsedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            gradient: AppColors.brandLeafGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 16,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sp8),
        Text(
          'Trang chủ',
          style: AppTypography.headingS.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
