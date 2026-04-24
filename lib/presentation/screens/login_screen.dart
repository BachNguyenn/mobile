import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Redesigned Login Screen — Japandi Minimalism
///
/// Thiết kế tối giản với:
/// - Zen illustration (CustomPainter)
/// - Logo + tên app
/// - Google Sign-In button
/// - Câu chào tiếng Nhật
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - MediaQuery.of(context).padding.top,
            child: Padding(
              padding: AppSpacing.paddingH24,
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ── Zen Illustration ─────────────────────────
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _LoginZenPainter(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp32),

                  // ── App Name ─────────────────────────────────
                  Text(
                    'Zen Japanese',
                    style: AppTypography.displayLarge.copyWith(
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp8),

                  // ── Japanese subtitle ────────────────────────
                  Text(
                    '日本語を学ぼう',
                    style: AppTypography.japaneseQuote.copyWith(
                      fontSize: 18,
                      color: AppColors.mossGreen,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp12),

                  Text(
                    'Hành trình học tiếng Nhật của bạn bắt đầu từ đây',
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.slateMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // ── Google Sign-In Button ────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement Google Sign-In
                      },
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slateGrey,
                            ),
                          ),
                        ),
                      ),
                      label: const Text('Đăng nhập với Google'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mossGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sp16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                        textStyle: AppTypography.bodyMBold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sp16),

                  // ── Continue as Guest ────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement guest mode
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slateGrey,
                        side: BorderSide(
                          color: AppColors.slateLight.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sp16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        ),
                      ),
                      child: Text(
                        'Tiếp tục không đăng nhập',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.slateGrey,
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // ── Footer ───────────────────────────────────
                  Text(
                    '一歩一歩、前に進もう',
                    style: AppTypography.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp4),
                  Text(
                    'Từng bước, tiến về phía trước',
                    style: AppTypography.labelS,
                  ),

                  const SizedBox(height: AppSpacing.sp32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter cho illustration Zen trên Login screen
class _LoginZenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ── Raked Sand Circles ─────────────────────────────────
    final sandPaint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 1; i <= 6; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY + 10),
        i * 18.0,
        sandPaint,
      );
    }

    // ── Zen Stones (3 đá) ──────────────────────────────────
    final stonePaint = Paint()
      ..color = AppColors.slateMuted.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Đá lớn giữa
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 32,
        height: 22,
      ),
      stonePaint,
    );

    // Đá nhỏ trái
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 40, centerY + 12),
        width: 20,
        height: 14,
      ),
      stonePaint,
    );

    // Đá nhỏ phải
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 35, centerY + 8),
        width: 16,
        height: 12,
      ),
      stonePaint,
    );

    // ── Bonsai cách điệu ──────────────────────────────────
    final trunkPaint = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Trunk
    canvas.drawLine(
      Offset(centerX - 65, centerY + 15),
      Offset(centerX - 65, centerY - 20),
      trunkPaint,
    );

    // Canopy
    final canopyPaint = Paint()
      ..color = AppColors.mossGreen.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - 65, centerY - 28),
      18,
      canopyPaint,
    );

    // ── Sakura petals ──────────────────────────────────────
    final petalPaint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final petalPositions = [
      Offset(centerX + 60, centerY - 30),
      Offset(centerX + 75, centerY - 15),
      Offset(centerX - 80, centerY - 40),
      Offset(centerX + 50, centerY + 30),
      Offset(centerX - 30, centerY - 45),
    ];

    for (final pos in petalPositions) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 6, height: 4),
        petalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
