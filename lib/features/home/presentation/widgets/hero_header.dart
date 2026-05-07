import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/core/models/progress_models.dart';

class HeroHeader extends StatefulWidget {
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

  @override
  State<HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _petalController;

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
  void initState() {
    super.initState();
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _petalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.overdueCount > 5;
    final motivation =
        _japaneseMotivations[DateTime.now().day % _japaneseMotivations.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        gradient: isWarning
            ? AppColors.heroWarningGradient
            : AppColors.heroGradient,
      ),
      child: Stack(
        children: [
          // ── Torii Gate Silhouette ──────────────────────
          Positioned(
            right: -20,
            top: 30,
            child: Opacity(
              opacity: 0.06,
              child: CustomPaint(
                size: const Size(180, 160),
                painter: _ToriiGatePainter(),
              ),
            ),
          ),

          // ── Floating Sakura Petals ────────────────────
          AnimatedBuilder(
            animation: _petalController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _SakuraPetalsPainter(
                  animationValue: _petalController.value,
                ),
              );
            },
          ),

          // ── Content ──────────────────────────────────
          SafeArea(
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

                  // Japanese motivation — paper card style
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp16,
                      vertical: AppSpacing.sp8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                      border: Border.all(
                        color: AppColors.gardenSandDark.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      motivation,
                      style: AppTypography.japaneseQuote.copyWith(
                        fontSize: 13,
                        color: AppColors.slateMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp16),

                  // Stat Chips Row — glassmorphism
                  Wrap(
                    spacing: AppSpacing.sp8,
                    runSpacing: AppSpacing.sp8,
                    children: [
                      _buildGlassStatChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '${widget.streak} ngày',
                        color: widget.streak > 0
                            ? AppColors.terracotta
                            : AppColors.slateMuted,
                      ),
                      _buildGlassStatChip(
                        icon: Icons.schedule_rounded,
                        value: '${widget.overdueCount} cần ôn',
                        color: widget.overdueCount > 5
                            ? AppColors.warning
                            : AppColors.slateMuted,
                      ),
                      _buildGlassStatChip(
                        icon: Icons.check_circle_outline_rounded,
                        value: '${widget.todayReviewed} hôm nay',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatChip({
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
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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

/// Torii Gate silhouette painter — decorative background element
class _ToriiGatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Top beam (kasagi) — curved
    final topBeam = Path();
    topBeam.moveTo(w * 0.05, h * 0.12);
    topBeam.quadraticBezierTo(w * 0.5, h * 0.02, w * 0.95, h * 0.12);
    topBeam.lineTo(w * 0.93, h * 0.18);
    topBeam.quadraticBezierTo(w * 0.5, h * 0.09, w * 0.07, h * 0.18);
    topBeam.close();
    canvas.drawPath(topBeam, paint);

    // Secondary beam (nuki) — straight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.25, w * 0.7, h * 0.04),
        const Radius.circular(2),
      ),
      paint,
    );

    // Left pillar (hashira)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.12, w * 0.06, h * 0.88),
        const Radius.circular(3),
      ),
      paint,
    );

    // Right pillar (hashira)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.72, h * 0.12, w * 0.06, h * 0.88),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating sakura petals — subtle ambient animation
class _SakuraPetalsPainter extends CustomPainter {
  final double animationValue;
  static final _rng = Random(42);

  _SakuraPetalsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 5; i++) {
      final baseX = _rng.nextDouble() * size.width;
      final baseY = _rng.nextDouble() * size.height * 0.7;
      final phase = i * 0.18;
      final t = (animationValue + phase) % 1.0;

      final dx = sin(t * pi * 2 + i) * 8;
      final dy = t * size.height * 0.25;
      final rotation = t * pi * 2;
      final opacity = (sin(t * pi) * 0.15).clamp(0.0, 0.15);

      canvas.save();
      canvas.translate(baseX + dx, baseY + dy);
      canvas.rotate(rotation);

      paint.color = AppColors.sakura.withValues(alpha: opacity);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 4 + _rng.nextDouble() * 3,
          height: 2.5 + _rng.nextDouble() * 1.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SakuraPetalsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
