import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

class SandRakePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw concentric circles to mimic raked sand
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 20; i < size.width + size.height; i += 40) {
      canvas.drawCircle(center, i.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
