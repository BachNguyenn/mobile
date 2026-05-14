import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/core/models/progress_models.dart';

class DailyProgressCard extends StatelessWidget {
  final HomeProgress progress;

  const DailyProgressCard({super.key, required this.progress});

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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.mossGreen.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left accent stripe ─────────────────────────
          Container(
            width: 4,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.mossGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sp16),

          // ── Card content ──────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tiến độ hôm nay', style: AppTypography.bodyMBold),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mossGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                      ),
                      child: Text(
                        '${progress.todayReviewed} thẻ đã ôn',
                        style: AppTypography.labelS.copyWith(
                          color: AppColors.mossGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp12),

                // Gradient progress bar
                _GradientProgressBar(
                  progress: progress.overallPercentage,
                  gradient: AppColors.mossGradient,
                ),

                const SizedBox(height: AppSpacing.sp16),

                // ── 3 Mini Stat Circles ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniStatCircle(
                      label: 'Từ vựng',
                      percentage: progress.vocabulary.percentage,
                      color: AppColors.waterBlue,
                    ),
                    _MiniStatCircle(
                      label: 'Ngữ pháp',
                      percentage: progress.grammar.percentage,
                      color: AppColors.sunGold,
                    ),
                    _MiniStatCircle(
                      label: 'Chữ Hán',
                      percentage: progress.kanji.percentage,
                      color: AppColors.mossGreen,
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

/// Gradient progress bar with a glowing dot at the leading edge
class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final LinearGradient gradient;

  const _GradientProgressBar({required this.progress, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0.0, 1.0);
        return SizedBox(
          height: 8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth * clampedValue;
              return Stack(
                children: [
                  // Track
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.creamDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Fill
                  if (barWidth > 0)
                    Container(
                      width: barWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mossGreen.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  // Leading dot glow
                  if (barWidth > 4)
                    Positioned(
                      left: barWidth - 4,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mossGreen.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MiniStatCircle extends StatelessWidget {
  final String label;
  final double percentage;
  final Color color;

  const _MiniStatCircle({
    required this.label,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasGlow = percentage > 0.5;

    return Column(
      children: [
        Container(
          decoration: hasGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                )
              : null,
          child: SizedBox(
            width: AppSpacing.miniStatSize,
            height: AppSpacing.miniStatSize,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: percentage),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: value,
                    color: color,
                    backgroundColor: AppColors.creamDark,
                    strokeWidth: 4,
                  ),
                  child: Center(
                    child: Text(
                      '${(value * 100).toInt()}%',
                      style: AppTypography.label.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          label,
          style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5708; // -π/2 (top)
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
