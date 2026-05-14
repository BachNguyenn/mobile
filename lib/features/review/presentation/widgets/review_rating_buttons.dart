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
    return Column(
      children: [
        Text('Bạn thấy chữ này thế nào?', style: AppTypography.bodyS),
        const SizedBox(height: AppSpacing.sp16),
        Row(
          children: [
            _RatingButton(
              label: 'Quên',
              color: AppColors.terracotta,
              rating: 1,
              onRate: onRate,
              enabled: enabled,
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Khó',
              color: AppColors.sunGold,
              rating: 2,
              onRate: onRate,
              enabled: enabled,
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Tốt',
              color: AppColors.mossGreen,
              rating: 3,
              onRate: onRate,
              enabled: enabled,
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Dễ',
              color: AppColors.waterBlue,
              rating: 4,
              onRate: onRate,
              enabled: enabled,
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final Color color;
  final int rating;
  final Future<void> Function(int) onRate;
  final bool enabled;

  const _RatingButton({
    required this.label,
    required this.color,
    required this.rating,
    required this.onRate,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: enabled ? () => onRate(rating) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            elevation: 0,
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
