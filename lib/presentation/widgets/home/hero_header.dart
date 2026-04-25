import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/progress_models.dart';

class HeroHeader extends StatelessWidget {
  final HomeProgress progress;
  final int streak;
  final int overdueCount;
  final int todayReviewed;

  const HeroHeader({
    super.key,
    required this.progress,
    required this.streak,
    required this.overdueCount,
    required this.todayReviewed,
  });

  /// Danh sách câu động viên tiếng Nhật ngẫu nhiên (theo ngày)
  static const _japaneseMotivations = [
    '一期一会 — Mỗi khoảnh khắc là duy nhất',
    '七転び八起き — Ngã bảy lần, đứng dậy tám',
    '継続 là sức mạnh — Kiên trì là sức mạnh',
    '花鳥風月 — Vẻ đẹp của thiên nhiên',
    '石の上にも三年 — Kiên nhẫn sẽ thành công',
    '初心忘るべからず — Đừng quên tâm ban đầu',
  ];

  @override
  Widget build(BuildContext context) {
    final isWarning = overdueCount > 5;
    final motivation = _japaneseMotivations[
      DateTime.now().day % _japaneseMotivations.length
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: isWarning
            ? AppColors.zenGardenWarningGradient
            : AppColors.zenGardenGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp24,
            AppSpacing.sp48,
            AppSpacing.sp24,
            AppSpacing.sp24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Greeting
              Text(
                'Chào mừng bạn trở lại,',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.slateMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                'Hôm nay bạn muốn học gì?',
                style: AppTypography.headingL,
              ),
              const SizedBox(height: AppSpacing.sp12),

              // Japanese motivation
              Text(
                motivation,
                style: AppTypography.japaneseQuote.copyWith(fontSize: 13),
              ),

              const SizedBox(height: AppSpacing.sp16),

              // Stat Chips Row
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.local_fire_department_rounded,
                    value: '$streak ngày',
                    color: streak > 0 ? AppColors.terracotta : AppColors.slateMuted,
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  _buildStatChip(
                    icon: Icons.schedule_rounded,
                    value: '$overdueCount cần ôn',
                    color: overdueCount > 5 ? AppColors.warning : AppColors.slateMuted,
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  _buildStatChip(
                    icon: Icons.check_circle_outline_rounded,
                    value: '$todayReviewed hôm nay',
                    color: AppColors.success,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            value,
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
