import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/zen_garden.dart';

/// Header Vườn Zen cho SliverAppBar
///
/// Hiển thị cảnh vườn Zen được vẽ bằng CustomPainter, với trạng thái
/// thay đổi động dựa trên dữ liệu FSRS (streak, overdue, EXP).
///
/// Mapping dữ liệu FSRS → UI:
/// - streak ≥ 7: Hoa đào nở (sakura particles)
/// - overdueCount > 5: Background chuyển vàng nhạt (cảnh báo)
/// - EXP cao: Nhiều cây/đá trong vườn hơn
/// - water: Suối chảy trong vườn
class ZenGardenHeader extends StatelessWidget {
  final ZenGarden garden;
  final int streak;
  final int overdueCount;
  final int todayReviewed;

  const ZenGardenHeader({
    super.key,
    required this.garden,
    required this.streak,
    required this.overdueCount,
    required this.todayReviewed,
  });

  /// Danh sách câu động viên tiếng Nhật ngẫu nhiên
  static const _japaneseMotivations = [
    '一期一会 — Mỗi khoảnh khắc là duy nhất',
    '七転び八起き — Ngã bảy lần, đứng dậy tám',
    '継続は力なり — Kiên trì là sức mạnh',
    '花鳥風月 — Vẻ đẹp của thiên nhiên',
    '石の上にも三年 — Kiên nhẫn sẽ thành công',
    '初心忘るべからず — Đừng quên tâm ban đầu',
  ];

  String get _randomMotivation {
    final index = DateTime.now().day % _japaneseMotivations.length;
    return _japaneseMotivations[index];
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = overdueCount > 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: isWarning
            ? AppColors.zenGardenWarningGradient
            : AppColors.zenGardenGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Zen Garden Scene (CustomPainter) ─────────────
          CustomPaint(
            painter: ZenGardenScenePainter(
              plantCount: garden.plants.length,
              hasWater: garden.water > 0,
              streak: streak,
              overdueCount: overdueCount,
            ),
          ),

          // ── Sakura Particles (khi streak ≥ 7) ───────────
          if (streak >= 7)
            CustomPaint(
              painter: SakuraParticlePainter(
                seed: DateTime.now().millisecond,
              ),
            ),

          // ── Bottom Content ──────────────────────────────
          Positioned(
            bottom: AppSpacing.sp48,
            left: AppSpacing.sp24,
            right: AppSpacing.sp24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  _randomMotivation,
                  style: AppTypography.japaneseQuote.copyWith(
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp16),

                // ── Stat Chips Row ───────────────────────
                Row(
                  children: [
                    _buildStatChip(
                      icon: Icons.local_fire_department_rounded,
                      value: '$streak ngày',
                      color: streak > 0
                          ? AppColors.terracotta
                          : AppColors.slateMuted,
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    _buildStatChip(
                      icon: Icons.schedule_rounded,
                      value: '$overdueCount cần ôn',
                      color: overdueCount > 5
                          ? AppColors.warning
                          : AppColors.slateMuted,
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
        ],
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

/// CustomPainter cho cảnh vườn Zen
///
/// Vẽ:
/// - Vòng tròn cát (raked sand patterns)
/// - Đá Zen (tùy theo plantCount)
/// - Suối nước (nếu hasWater)
/// - Cây bonsai cách điệu
class ZenGardenScenePainter extends CustomPainter {
  final int plantCount;
  final bool hasWater;
  final int streak;
  final int overdueCount;

  ZenGardenScenePainter({
    required this.plantCount,
    required this.hasWater,
    required this.streak,
    required this.overdueCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Raked Sand Circles ─────────────────────────────────
    final sandPaint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final centerX = size.width * 0.7;
    final centerY = size.height * 0.4;

    for (var i = 1; i <= 8; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        i * 22.0,
        sandPaint,
      );
    }

    // ── Zen Stones ────────────────────────────────────────
    final stonePaint = Paint()
      ..color = AppColors.slateMuted.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Đá chính (luôn hiển thị)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 28,
        height: 20,
      ),
      stonePaint,
    );

    // Đá phụ (hiển thị khi có plants)
    if (plantCount > 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX - 35, centerY + 15),
          width: 18,
          height: 14,
        ),
        stonePaint,
      );
    }

    if (plantCount > 2) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX + 30, centerY - 20),
          width: 14,
          height: 10,
        ),
        stonePaint,
      );
    }

    // ── Water Stream (nếu có nước) ────────────────────────
    if (hasWater) {
      final waterPaint = Paint()
        ..color = AppColors.waterBlue.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      final waterPath = Path();
      waterPath.moveTo(size.width * 0.1, size.height * 0.3);
      waterPath.cubicTo(
        size.width * 0.25, size.height * 0.35,
        size.width * 0.35, size.height * 0.45,
        size.width * 0.5, size.height * 0.5,
      );
      canvas.drawPath(waterPath, waterPaint);
    }

    // ── Bonsai (khi streak > 0) ───────────────────────────
    if (streak > 0) {
      _drawBonsai(canvas, Offset(size.width * 0.15, size.height * 0.55), streak);
    }
  }

  void _drawBonsai(Canvas canvas, Offset position, int streak) {
    // Trunk
    final trunkPaint = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      position,
      Offset(position.dx, position.dy - 25),
      trunkPaint,
    );

    // Canopy — lớn hơn khi streak cao
    final canopySize = 12.0 + min(streak.toDouble(), 15.0);
    final canopyPaint = Paint()
      ..color = AppColors.mossGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(position.dx, position.dy - 30),
      canopySize,
      canopyPaint,
    );

    // Hoa (khi streak ≥ 7)
    if (streak >= 7) {
      final flowerPaint = Paint()
        ..color = AppColors.sakura.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < 3; i++) {
        final angle = i * 2.1;
        canvas.drawCircle(
          Offset(
            position.dx + cos(angle) * canopySize * 0.6,
            position.dy - 30 + sin(angle) * canopySize * 0.6,
          ),
          3.5,
          flowerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ZenGardenScenePainter oldDelegate) {
    return oldDelegate.plantCount != plantCount ||
        oldDelegate.hasWater != hasWater ||
        oldDelegate.streak != streak ||
        oldDelegate.overdueCount != overdueCount;
  }
}

/// Painter cho hiệu ứng hoa đào rơi (khi streak ≥ 7)
class SakuraParticlePainter extends CustomPainter {
  final int seed;

  SakuraParticlePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(seed);
    final paint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      final radius = 2.0 + rng.nextDouble() * 3;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: radius * 1.5,
          height: radius,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SakuraParticlePainter oldDelegate) => false;
}
