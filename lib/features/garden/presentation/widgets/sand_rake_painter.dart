import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Rich karesansui (枯山水) sand pattern painter.
///
/// Draws:
/// - Flowing wave patterns inspired by real zen garden raked sand
/// - Concentric patterns around stone positions
/// - Fine sand grain noise for texture
class SandRakePainter extends CustomPainter {
  final List<Offset> stonePositions;

  SandRakePainter({this.stonePositions = const []});

  @override
  void paint(Canvas canvas, Size size) {
    _drawSandGrain(canvas, size);
    _drawFlowingWaves(canvas, size);
    _drawCirclePatterns(canvas, size);
  }

  /// Fine dot pattern for sand texture
  void _drawSandGrain(Canvas canvas, Size size) {
    final rng = Random(99);
    final paint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.5 + rng.nextDouble() * 0.5, paint);
    }
  }

  /// Flowing S-curve rake lines across the garden
  void _drawFlowingWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    // Horizontal flowing waves
    for (var i = 0; i < 14; i++) {
      final y = 20.0 + i * (size.height / 14);
      final path = Path();
      path.moveTo(-10, y);

      for (var x = 0.0; x <= size.width + 20; x += 30) {
        final amplitude = 4.0 + sin(i * 0.5) * 3;
        final cy = y + sin(x / 50 + i * 0.7) * amplitude;
        path.lineTo(x, cy);
      }

      // Check if this line should curve around any stones
      bool tooClose = false;
      for (final stone in stonePositions) {
        if ((stone.dy - y).abs() < 40) {
          tooClose = true;
          break;
        }
      }

      if (!tooClose) {
        canvas.drawPath(path, paint);
      }
    }

    // Additional curved lines at edges
    final edgePaint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final x = size.width * 0.85 + i * 6;
      path.moveTo(x, 0);
      path.quadraticBezierTo(
        x + 10,
        size.height * 0.5,
        x - 5,
        size.height,
      );
      canvas.drawPath(path, edgePaint);
    }
  }

  /// Concentric circle patterns around stone positions
  void _drawCirclePatterns(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gardenSandDark.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    if (stonePositions.isEmpty) {
      // Default center pattern
      final center = Offset(size.width * 0.5, size.height * 0.5);
      for (var r = 25; r < 120; r += 18) {
        canvas.drawOval(
          Rect.fromCenter(
            center: center,
            width: r * 2.0,
            height: r * 1.3,
          ),
          paint,
        );
      }
    } else {
      for (final stone in stonePositions) {
        for (var r = 15; r < 60; r += 12) {
          canvas.drawOval(
            Rect.fromCenter(
              center: stone,
              width: r * 2.0,
              height: r * 1.4,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SandRakePainter oldDelegate) {
    return oldDelegate.stonePositions != stonePositions;
  }
}
