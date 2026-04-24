import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Card lớn cho menu học tập trên Home screen
///
/// Hiển thị: icon tối giản, tên mục, mô tả ngắn, và progress bar.
/// Hỗ trợ Hero animation khi chuyển sang detail screen.
///
/// ```dart
/// LearningCard(
///   title: 'Chữ Hán',
///   subtitle: '214 bộ thủ cơ bản',
///   icon: Icons.translate_rounded,
///   progress: 0.35,
///   heroTag: 'kanji',
///   accentColor: AppColors.mossGreen,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class LearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final double progress;
  final String heroTag;
  final Color accentColor;
  final VoidCallback onTap;

  const LearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.progress,
    required this.heroTag,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            height: AppSpacing.learningCardHeight,
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              border: Border.all(
                color: AppColors.slateLight.withValues(alpha: 0.3),
                width: 1,
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
                // ── Top Row: Icon + Title + Percentage ──────────
                Expanded(
                  child: Row(
                    children: [
                      // Icon container
                      Container(
                        width: AppSpacing.iconContainerSize,
                        height: AppSpacing.iconContainerSize,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                        child: Icon(
                          icon,
                          size: 24,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp16),

                      // Title + Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title, style: AppTypography.headingS),
                            const SizedBox(height: AppSpacing.sp4),
                            Text(subtitle, style: AppTypography.caption),
                          ],
                        ),
                      ),

                      // Percentage
                      Text(
                        '$percentage%',
                        style: AppTypography.statNumber.copyWith(
                          color: accentColor,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.sp12),

                // ── Bottom: Progress Bar ─────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.progressBarHeight / 2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: AppSpacing.progressBarHeight,
                        backgroundColor: AppColors.creamDark,
                        valueColor: AlwaysStoppedAnimation(accentColor),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
