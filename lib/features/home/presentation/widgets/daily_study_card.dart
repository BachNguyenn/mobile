import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class DailyStudyCard extends StatelessWidget {
  final AsyncValue<DailyStudyPlan> plan;
  final HomeProgress progress;
  final ValueChanged<DailyStudyPlan> onTap;

  const DailyStudyCard({
    super.key,
    required this.plan,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress.overallPercentage * 100).round();
    final currentPlan = plan.value;
    final title = currentPlan?.title ?? 'Đang chọn phiên học';
    final subtitle =
        currentPlan?.subtitle ?? 'Đang chọn phiên học phù hợp cho bạn.';
    final compactReason =
        currentPlan?.reason.replaceFirst(' đến hạn', '') ??
        'Dựa trên tiến độ hiện tại';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);
    return AppCard(
      onTap: currentPlan == null ? null : () => onTap(currentPlan),
      color: isDark ? null : resolvedZenBlue,
      borderColor: isDark
          ? const Color(0xFF353F6C).withValues(alpha: 0.4)
          : resolvedZenBlue,
      gradient: isDark
          ? const LinearGradient(
              colors: [Color(0xFF1F2544), Color(0xFF151A30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      shadowColor: isDark
          ? Colors.transparent
          : resolvedZenBlue.withValues(alpha: 0.16),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp16,
        AppSpacing.sp12,
        AppSpacing.sp16,
        AppSpacing.sp12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp8,
                  vertical: AppSpacing.sp4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.leafLight,
                    ),
                    const SizedBox(width: AppSpacing.sp4),
                    Text(
                      'Hôm nay học gì?',
                      style: AppTypography.label.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (currentPlan != null)
                _DailyStudyPill(
                  icon: Icons.flag_rounded,
                  label: 'N${currentPlan.level}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingM.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.white.withValues(alpha: 0.74),
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: [
              _DailyStudyPill(
                icon: Icons.tips_and_updates_rounded,
                label: compactReason,
              ),
              if (currentPlan != null && currentPlan.itemCount > 0)
                _DailyStudyPill(
                  icon: Icons.format_list_numbered_rounded,
                  label: '${currentPlan.itemCount} mục',
                ),
              _DailyStudyPill(icon: Icons.insights_rounded, label: '$percent%'),
              _DailyStudyPill(
                icon: Icons.local_fire_department_rounded,
                label: '${progress.streak} ngày',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: progress.overallPercentage.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.leafLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Row(
            children: [
              Text(
                currentPlan == null ? 'Đang chuẩn bị' : 'Bắt đầu ngay',
                style: AppTypography.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white.withValues(
                  alpha: currentPlan == null ? 0.5 : 1,
                ),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyStudyPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DailyStudyPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white.withValues(alpha: 0.82)),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelS.copyWith(
              color: AppColors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
