import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';

class AnalyticsStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const AnalyticsStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      color: AppColors.white,
      borderColor: color.withValues(alpha: 0.18),
      shadowColor: color.withValues(alpha: 0.05),
      child: Column(
        children: [
          Text(value, style: AppTypography.statNumber.copyWith(color: color)),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.label.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
