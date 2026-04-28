import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/models/progress_models.dart';

class LibraryProgressCard extends StatelessWidget {
  final ModuleProgress progress;
  final int dueCount;
  final String title;
  final IconData icon;
  final Color color;

  const LibraryProgressCard({
    super.key,
    required this.progress,
    required this.dueCount,
    this.title = 'Chữ Hán',
    this.icon = Icons.translate_rounded,
    this.color = AppColors.mossGreen,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress.percentage * 100).toInt();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ────────────────────────────────
          Row(
            children: [
              // Icon
              Container(
                width: AppSpacing.iconContainerSize,
                height: AppSpacing.iconContainerSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: AppSpacing.sp16),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.headingS),
                    const SizedBox(height: 2),
                    Text(
                      '${progress.learned}/${progress.total} đã học',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),

              // Percentage
              Text(
                '$percentage%',
                style: AppTypography.statNumber.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sp12),

          // ── Progress Bar ──────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppSpacing.progressBarHeight / 2,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.percentage),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: AppSpacing.progressBarHeight,
                  backgroundColor: AppColors.creamDark,
                  valueColor:
                      AlwaysStoppedAnimation(color),
                );
              },
            ),
          ),

          // ── Stats Row ─────────────────────────────────
          if (dueCount > 0 || progress.learned > 0) ...[
            const SizedBox(height: AppSpacing.sp12),
            Row(
              children: [
                if (dueCount > 0) ...[
                  _buildMiniChip(
                    Icons.schedule_rounded,
                    '$dueCount cần ôn',
                    AppColors.terracotta,
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                ],
                _buildMiniChip(
                  Icons.check_circle_outline_rounded,
                  '${progress.learned} đã học',
                  AppColors.success,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: AppTypography.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
