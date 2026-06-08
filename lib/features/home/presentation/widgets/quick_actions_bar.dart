import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class QuickActionsBar extends StatelessWidget {
  final VoidCallback onOpenWeakness;
  final VoidCallback onOpenPlacement;
  final VoidCallback onOpenSentencePractice;
  final VoidCallback onOpenGarden;
  final VoidCallback onOpenAnalytics;

  const QuickActionsBar({
    super.key,
    required this.onOpenWeakness,
    required this.onOpenPlacement,
    required this.onOpenSentencePractice,
    required this.onOpenGarden,
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lối tắt',
          style: AppTypography.headingS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.fact_check_rounded,
                label: 'Test đầu vào',
                onTap: onOpenPlacement,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.record_voice_over_rounded,
                label: 'Luyện câu',
                onTap: onOpenSentencePractice,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.yard_rounded,
                label: 'Vườn',
                onTap: onOpenGarden,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.psychology_alt_rounded,
                label: 'Điểm yếu',
                onTap: onOpenWeakness,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.insights_rounded,
                label: 'Hồ sơ',
                onTap: onOpenAnalytics,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBlue = AppColors.resolve(AppColors.zenBlue, context);
    return Material(
      color: resolvedBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: resolvedBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: resolvedBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
