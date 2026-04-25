import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/progress_models.dart';

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
        border: Border.all(
          color: AppColors.slateLight.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiến độ hôm nay', style: AppTypography.bodyMBold),
              Text(
                '${progress.todayReviewed} thẻ đã ôn',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),

          // Overall progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppSpacing.progressBarHeight / 2,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.overallPercentage),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: AppSpacing.progressBarHeight,
                  backgroundColor: AppColors.creamDark,
                  valueColor: const AlwaysStoppedAnimation(AppColors.mossGreen),
                );
              },
            ),
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
    return Column(
      children: [
        SizedBox(
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
        const SizedBox(height: AppSpacing.sp4),
        Text(
          label,
          style: AppTypography.labelS.copyWith(
            color: AppColors.slateMuted,
          ),
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
    final sweepAngle = 2 * 3.14159265 * progress.clamp(0.0, 1.0);

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
