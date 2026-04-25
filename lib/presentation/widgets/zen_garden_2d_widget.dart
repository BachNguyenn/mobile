import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/entities/zen_garden.dart';

/// Compact 2D Zen Garden widget hiển thị trên Home screen.
///
/// Vẽ cảnh vườn Zen thu nhỏ bằng CustomPainter:
/// - Nền cát với vân cát raked
/// - Đá, bonsai, hoa đào (dựa trên garden state)
/// - Suối nước nếu garden.water > 0
/// - Badge EXP level góc phải
///
/// Tap để mở full GardenScreen.
class ZenGarden2DWidget extends StatefulWidget {
  final ZenGarden garden;
  final int streak;
  final VoidCallback onTap;

  const ZenGarden2DWidget({
    super.key,
    required this.garden,
    required this.streak,
    required this.onTap,
  });

  @override
  State<ZenGarden2DWidget> createState() => _ZenGarden2DWidgetState();
}

class _ZenGarden2DWidgetState extends State<ZenGarden2DWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: AppSpacing.miniGardenHeight,
        decoration: BoxDecoration(
          color: AppColors.gardenSand,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          border: Border.all(
            color: AppColors.gardenSandDark.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          child: Stack(
            children: [
              // ── 2D Garden Scene ──────────────────────────
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _MiniGardenPainter(
                      garden: widget.garden,
                      streak: widget.streak,
                      animationValue: _shimmerController.value,
                    ),
                  );
                },
              ),

              // ── Top Label ───────────────────────────────
              Positioned(
                top: AppSpacing.sp12,
                left: AppSpacing.sp16,
                child: Row(
                  children: [
                    Icon(
                      Icons.park_rounded,
                      size: 16,
                      color: AppColors.mossDark.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AppSpacing.sp4),
                    Text(
                      'Khu vườn Zen',
                      style: AppTypography.label.copyWith(
                        color: AppColors.mossDark.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── EXP Badge ──────────────────────────────
              Positioned(
                top: AppSpacing.sp12,
                right: AppSpacing.sp16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp8,
                    vertical: AppSpacing.sp4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mossGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                    border: Border.all(
                      color: AppColors.mossGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 12,
                        color: AppColors.mossGreen,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.garden.exp} EXP',
                        style: AppTypography.labelS.copyWith(
                          color: AppColors.mossGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bottom hint ─────────────────────────────
              Positioned(
                bottom: AppSpacing.sp12,
                right: AppSpacing.sp16,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chạm để khám phá',
                      style: AppTypography.labelS.copyWith(
                        color: AppColors.slateMuted.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.slateMuted.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),

              // ── Plant count ─────────────────────────────
              Positioned(
                bottom: AppSpacing.sp12,
                left: AppSpacing.sp16,
                child: Row(
                  children: [
                    _buildMiniStat(
                      Icons.eco_rounded,
                      '${widget.garden.plants.length}',
                      AppColors.mossGreen,
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    _buildMiniStat(
                      Icons.water_drop_rounded,
                      '${widget.garden.water}',
                      AppColors.waterBlue,
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    _buildMiniStat(
                      Icons.wb_sunny_rounded,
                      '${widget.garden.sunlight}',
                      AppColors.sunGold,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 2),
        Text(
          value,
          style: AppTypography.labelS.copyWith(
            color: color.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// CustomPainter cho 2D garden mini scene
class _MiniGardenPainter extends CustomPainter {
  final ZenGarden garden;
  final int streak;
  final double animationValue;

  _MiniGardenPainter({
    required this.garden,
    required this.streak,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawRakedSand(canvas, size);
    _drawStones(canvas, size);

    if (garden.water > 0) {
      _drawWaterStream(canvas, size);
    }

    if (streak > 0) {
      _drawBonsai(canvas, size);
    }

    // Draw placed plants
    for (final plant in garden.plants) {
      _drawPlant(canvas, size, plant);
    }

    // Sakura petals when streak >= 7
    if (streak >= 7) {
      _drawSakuraPetals(canvas, size);
    }
  }

  void _drawRakedSand(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Concentric ellipses centered slightly right
    final cx = size.width * 0.55;
    final cy = size.height * 0.5;

    for (var i = 1; i <= 10; i++) {
      final rx = i * 18.0;
      final ry = i * 12.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        paint,
      );
    }

    // Additional arc lines at left side
    final arcPaint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final y = 30.0 + i * 20.0;
      path.moveTo(0, y);
      path.quadraticBezierTo(size.width * 0.15, y + 8, size.width * 0.25, y);
      canvas.drawPath(path, arcPaint);
    }
  }

  void _drawStones(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.slateMuted.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // Main stone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.55, size.height * 0.48),
        width: 22,
        height: 14,
      ),
      paint,
    );

    // Stone highlight
    final highlightPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.54, size.height * 0.46),
        width: 10,
        height: 5,
      ),
      highlightPaint,
    );

    // Secondary stone
    if (garden.plants.isNotEmpty) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.42, size.height * 0.58),
          width: 14,
          height: 10,
        ),
        paint,
      );
    }

    // Tertiary stone
    if (garden.plants.length > 2) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.68, size.height * 0.4),
          width: 10,
          height: 7,
        ),
        paint,
      );
    }
  }

  void _drawWaterStream(Canvas canvas, Size size) {
    final shimmer = sin(animationValue * 2 * pi) * 3;

    final waterPaint = Paint()
      ..color = AppColors.waterBlue.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.08, size.height * 0.35 + shimmer);
    path.cubicTo(
      size.width * 0.2, size.height * 0.4 + shimmer,
      size.width * 0.3, size.height * 0.5 - shimmer,
      size.width * 0.42, size.height * 0.52,
    );
    canvas.drawPath(path, waterPaint);

    // Shimmer dots on water
    final dotPaint = Paint()
      ..color = AppColors.waterBlue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final dotX = size.width * (0.15 + animationValue * 0.25);
    final dotY = size.height * 0.38 + sin(animationValue * pi * 2) * 4;
    canvas.drawCircle(Offset(dotX, dotY), 1.5, dotPaint);
  }

  void _drawBonsai(Canvas canvas, Size size) {
    final baseX = size.width * 0.18;
    final baseY = size.height * 0.7;

    // Trunk
    final trunkPaint = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(baseX, baseY),
      Offset(baseX - 2, baseY - 20),
      trunkPaint,
    );

    // Branch
    canvas.drawLine(
      Offset(baseX - 2, baseY - 15),
      Offset(baseX + 8, baseY - 22),
      trunkPaint..strokeWidth = 1.5,
    );

    // Canopy (grows with streak)
    final canopySize = 10.0 + min(streak.toDouble(), 12.0);
    final canopyPaint = Paint()
      ..color = AppColors.mossGreen.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY - 26),
        width: canopySize * 2,
        height: canopySize * 1.3,
      ),
      canopyPaint,
    );

    // Second canopy cluster
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX + 7, baseY - 24),
        width: canopySize * 1.2,
        height: canopySize * 0.8,
      ),
      canopyPaint,
    );
  }

  void _drawPlant(Canvas canvas, Size size, Plant plant) {
    // Map plant position to mini canvas (scaled down)
    final x = (plant.x / 350.0).clamp(0.1, 0.9) * size.width;
    final y = (plant.y / 300.0).clamp(0.2, 0.8) * size.height;

    Color color;
    switch (plant.type) {
      case 'bonsai':
        color = AppColors.mossDark;
        // Mini tree
        final trunkPaint = Paint()
          ..color = AppColors.terracotta.withValues(alpha: 0.4)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x, y), Offset(x, y - 8), trunkPaint);
        canvas.drawCircle(
          Offset(x, y - 10),
          5.0 + plant.level,
          Paint()..color = color.withValues(alpha: 0.3),
        );
        break;
      case 'flower':
        color = AppColors.sakura;
        // Flower dots
        for (var i = 0; i < 4; i++) {
          final angle = i * pi / 2;
          canvas.drawCircle(
            Offset(x + cos(angle) * 3, y + sin(angle) * 3),
            2,
            Paint()..color = color.withValues(alpha: 0.5),
          );
        }
        canvas.drawCircle(
          Offset(x, y),
          1.5,
          Paint()..color = AppColors.sunGold.withValues(alpha: 0.5),
        );
        break;
      case 'stone':
        color = AppColors.slateGrey;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 8.0 + plant.level,
            height: 5.0 + plant.level * 0.5,
          ),
          Paint()..color = color.withValues(alpha: 0.25),
        );
        break;
      default:
        color = AppColors.bambooGreen;
        // Bamboo sticks
        final stickPaint = Paint()
          ..color = color.withValues(alpha: 0.4)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(x, y), Offset(x, y - 12), stickPaint);
        canvas.drawLine(Offset(x + 3, y), Offset(x + 3, y - 10), stickPaint);
    }
  }

  void _drawSakuraPetals(Canvas canvas, Size size) {
    final rng = Random(42); // Deterministic for consistency
    final paint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 6; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height * 0.6;
      // Animate falling with time offset
      final dy = (animationValue + i * 0.15) % 1.0 * size.height * 0.3;
      final dx = sin((animationValue + i * 0.2) * pi * 2) * 5;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(baseX + dx, baseY + dy),
          width: 3 + rng.nextDouble() * 2,
          height: 2 + rng.nextDouble(),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MiniGardenPainter oldDelegate) {
    return oldDelegate.garden != garden ||
        oldDelegate.streak != streak ||
        oldDelegate.animationValue != animationValue;
  }
}
