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
    final resolvedColor = AppColors.resolve(color, context);
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      color: Theme.of(context).cardColor,
      borderColor: resolvedColor.withValues(alpha: 0.18),
      shadowColor: resolvedColor.withValues(alpha: 0.05),
      child: Column(
        children: [
          Text(value, style: AppTypography.statNumber.copyWith(color: resolvedColor)),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.label.copyWith(color: resolvedColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
