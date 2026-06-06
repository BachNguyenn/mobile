import 'package:flutter/material.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class HeroHeader extends StatelessWidget {
  final HomeProgress progress;
  final int streak;
  final int overdueCount;
  final int todayReviewed;
  final VoidCallback? onStartLearning;
  final VoidCallback? onSearch;

  const HeroHeader({
    super.key,
    required this.progress,
    required this.streak,
    required this.overdueCount,
    required this.todayReviewed,
    this.onStartLearning,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = overdueCount > 5;
    final gradient = isWarning
        ? AppColors.heroWarningGradient
        : AppColors.heroGradient;
    final resolvedGradient = LinearGradient(
      colors: AppColors.resolveColors(gradient.colors, context),
      begin: gradient.begin,
      end: gradient.end,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: resolvedGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        boxShadow: AppColors.softShadow(
          context,
          color: AppColors.resolve(AppColors.navyDark, context).withValues(alpha: 0.20),
          blurRadius: 28,
          offset: const Offset(0, 16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _InkCirclePainter(
                color: AppColors.white.withValues(alpha: 0.10),
                leafColor: AppColors.resolve(AppColors.leafLight, context),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/app_logo_clean.png',
                        fit: BoxFit.cover,
                        cacheWidth: 88,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Zen Japanese',
                            style: AppTypography.label.copyWith(
                              color: AppColors.white.withValues(alpha: 0.78),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Trang chủ',
                            style: AppTypography.headingS.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeroIconButton(
                      icon: Icons.search_rounded,
                      tooltip: 'Tìm kiếm',
                      onTap: onSearch,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp24),
                Text(
                  'Chào bạn trở lại',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.white.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  overdueCount > 0
                      ? 'Có $overdueCount mục đang chờ ôn.'
                      : 'Hôm nay bắt đầu nhẹ nhàng thôi.',
                  style: AppTypography.headingL.copyWith(
                    color: AppColors.white,
                    fontSize: 26,
                    height: 1.18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp20),
                Row(
                  children: [
                    Expanded(
                      child: _HeroStatTile(
                        icon: Icons.check_circle_rounded,
                        value: '$todayReviewed',
                        label: 'Đã ôn',
                        color: AppColors.leafLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    Expanded(
                      child: _HeroStatTile(
                        icon: Icons.schedule_rounded,
                        value: '$overdueCount',
                        label: 'Cần ôn',
                        color: overdueCount > 0
                            ? AppColors.sunGold
                            : AppColors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    Expanded(
                      child: _HeroStatTile(
                        icon: Icons.local_fire_department_rounded,
                        value: '$streak',
                        label: 'Streak',
                        color: streak > 0
                            ? AppColors.terracotta
                            : AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp20),
                Row(
                  children: [
                    Expanded(
                      child: _PrimaryHeroButton(
                        label: 'Bắt đầu học',
                        icon: Icons.play_arrow_rounded,
                        onTap: onStartLearning,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    _SecondaryHeroButton(
                      icon: Icons.manage_search_rounded,
                      label: 'Tra cứu',
                      onTap: onSearch,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _HeroStatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: resolvedColor),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            value,
            style: AppTypography.statNumber.copyWith(
              color: AppColors.white,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelS.copyWith(
              color: AppColors.white.withValues(alpha: 0.68),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryHeroButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PrimaryHeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: resolvedZenBlue, size: 22),
              const SizedBox(width: AppSpacing.sp8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMBold.copyWith(
                    color: resolvedZenBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryHeroButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryHeroButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _InkCirclePainter extends CustomPainter {
  final Color color;
  final Color leafColor;

  const _InkCirclePainter({required this.color, required this.leafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: Offset(size.width * 0.90, size.height * 0.16),
      radius: size.width * 0.35,
    );
    canvas.drawArc(rect, 0.30, 4.9, false, paint);

    final leafPaint = Paint()
      ..color = leafColor.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final leaf = Path()
      ..moveTo(size.width * 0.80, size.height * 0.05)
      ..quadraticBezierTo(
        size.width * 1.05,
        size.height * 0.03,
        size.width * 0.96,
        size.height * 0.31,
      )
      ..quadraticBezierTo(
        size.width * 0.77,
        size.height * 0.26,
        size.width * 0.80,
        size.height * 0.05,
      );
    canvas.drawPath(leaf, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _InkCirclePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.leafColor != leafColor;
  }
}
