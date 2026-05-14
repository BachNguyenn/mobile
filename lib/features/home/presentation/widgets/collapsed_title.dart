import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';

class CollapsedTitle extends StatelessWidget {
  const CollapsedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mini torii icon
        SizedBox(
          width: 18,
          height: 16,
          child: CustomPaint(painter: _MiniToriiPainter()),
        ),
        const SizedBox(width: 8),
        Text(
          '禅 · Zen Japanese',
          style: AppTypography.headingS.copyWith(
            color: AppColors.ink,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

/// Tiny torii gate icon for the collapsed app bar title
class _MiniToriiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Top beam
    final topBeam = Path();
    topBeam.moveTo(0, h * 0.15);
    topBeam.quadraticBezierTo(w * 0.5, 0, w, h * 0.15);
    topBeam.lineTo(w * 0.95, h * 0.25);
    topBeam.quadraticBezierTo(w * 0.5, h * 0.12, w * 0.05, h * 0.25);
    topBeam.close();
    canvas.drawPath(topBeam, paint);

    // Lower beam
    canvas.drawRect(
      Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.7, h * 0.06),
      paint,
    );

    // Left pillar
    canvas.drawRect(
      Rect.fromLTWH(w * 0.22, h * 0.15, w * 0.08, h * 0.85),
      paint,
    );

    // Right pillar
    canvas.drawRect(
      Rect.fromLTWH(w * 0.7, h * 0.15, w * 0.08, h * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
