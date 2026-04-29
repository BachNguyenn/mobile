import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AnalyticsWeeklyChart extends StatelessWidget {
  final List<double> weeklyData;

  const AnalyticsWeeklyChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.sp16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (index) {
          final percent = index < weeklyData.length ? weeklyData[index] : 0.0;
          return _Bar(day: days[index], percent: percent);
        }),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final String day;
  final double percent;

  const _Bar({required this.day, required this.percent});

  @override
  Widget build(BuildContext context) {
    final value = percent.clamp(0.0, 1.0).toDouble();

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 12,
          height: 140 * value,
          decoration: BoxDecoration(
            color: AppColors.mossGreen,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),
        Text(day, style: AppTypography.labelS),
      ],
    );
  }
}
