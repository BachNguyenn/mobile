import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AnalyticsJlptProgress extends StatelessWidget {
  final Map<String, double> progress;

  const AnalyticsJlptProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.2)),
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
          Text(
            'Phân bổ theo JLPT',
            style: AppTypography.headingS.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sp16),
          _JlptProgressRow(
            level: 'N5',
            percent: progress['N5'] ?? 0,
            color: AppColors.mossGreen,
          ),
          _JlptProgressRow(
            level: 'N4',
            percent: progress['N4'] ?? 0,
            color: AppColors.waterBlue,
          ),
          _JlptProgressRow(
            level: 'N3',
            percent: progress['N3'] ?? 0,
            color: AppColors.sunGold,
          ),
          _JlptProgressRow(
            level: 'N2',
            percent: progress['N2'] ?? 0,
            color: AppColors.terracotta,
          ),
          _JlptProgressRow(
            level: 'N1',
            percent: progress['N1'] ?? 0,
            color: AppColors.sakura,
          ),
        ],
      ),
    );
  }
}

class _JlptProgressRow extends StatelessWidget {
  final String level;
  final double percent;
  final Color color;

  const _JlptProgressRow({
    required this.level,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              level,
              style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: color.withValues(alpha: 0.1),
              color: color,
              borderRadius: BorderRadius.circular(10),
              minHeight: 8,
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Text(
            '${(value * 100).toInt()}%',
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}
