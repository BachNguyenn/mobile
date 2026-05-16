import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class ReviewRatingButtons extends StatelessWidget {
  final Future<void> Function(int) onRate;
  final bool enabled;

  const ReviewRatingButtons({
    super.key,
    required this.onRate,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Bạn nhớ thẻ này thế nào?',
            style: AppTypography.label.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.sp12),
          Row(
            children: [
              _RatingButton(
                label: 'Quên',
                icon: Icons.close_rounded,
                color: AppColors.terracotta,
                rating: 1,
                onRate: onRate,
                enabled: enabled,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _RatingButton(
                label: 'Khó',
                icon: Icons.priority_high_rounded,
                color: AppColors.sunGold,
                rating: 2,
                onRate: onRate,
                enabled: enabled,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _RatingButton(
                label: 'Tốt',
                icon: Icons.check_rounded,
                color: AppColors.leafGreen,
                rating: 3,
                onRate: onRate,
                enabled: enabled,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _RatingButton(
                label: 'Dễ',
                icon: Icons.bolt_rounded,
                color: AppColors.waterBlue,
                rating: 4,
                onRate: onRate,
                enabled: enabled,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int rating;
  final Future<void> Function(int) onRate;
  final bool enabled;

  const _RatingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.rating,
    required this.onRate,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        child: InkWell(
          onTap: enabled ? () => onRate(rating) : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: enabled ? color : AppColors.slateMuted,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelS.copyWith(
                    color: enabled ? color : AppColors.slateMuted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
