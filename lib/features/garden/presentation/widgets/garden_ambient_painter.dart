import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Ambient atmospheric effects for the Zen Garden.
///
/// Draws:
/// - Floating golden dust motes with slow brownian motion
/// - Subtle light rays from the top-right corner
class GardenAmbientPainter extends CustomPainter {
  final double animationValue;
  static final _rng = Random(77);

  // Pre-compute dust positions for consistency
  static final List<_DustMote> _motes = List.generate(
    12,
    (_) => _DustMote(
      baseX: _rng.nextDouble(),
      baseY: _rng.nextDouble(),
      size: 1.0 + _rng.nextDouble() * 2.0,
      speed: 0.3 + _rng.nextDouble() * 0.7,
      phase: _rng.nextDouble() * pi * 2,
    ),
  );

  GardenAmbientPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    _drawLightRays(canvas, size);
    _drawDustMotes(canvas, size);
  }

  void _drawLightRays(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.lightRay.withValues(alpha: 0.08),
          AppColors.lightRay.withValues(alpha: 0.0),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw 3 diagonal light ray bands
    for (var i = 0; i < 3; i++) {
      final offset = i * size.width * 0.25;
      final shimmer = sin(animationValue * pi * 2 + i * 0.8) * 0.02;

      final path = Path();
      path.moveTo(size.width - offset, 0);
      path.lineTo(size.width - offset + size.width * 0.08, 0);
      path.lineTo(0, size.height - offset + size.height * 0.08);
      path.lineTo(0, size.height - offset);
      path.close();

      canvas.save();
      canvas.drawPath(
        path,
        rayPaint..color = AppColors.lightRay.withValues(alpha: 0.04 + shimmer),
      );
      canvas.restore();
    }
  }

  void _drawDustMotes(Canvas canvas, Size size) {
    for (final mote in _motes) {
      final t = (animationValue * mote.speed + mote.phase) % 1.0;

      // Brownian-like motion
      final dx = sin(t * pi * 4 + mote.phase) * 6;
      final dy = cos(t * pi * 3 + mote.phase * 0.7) * 4;

      final x = mote.baseX * size.width + dx;
      final y = mote.baseY * size.height + dy;

      // Pulsing opacity
      final opacity = (sin(t * pi * 2) * 0.3 + 0.3).clamp(0.0, 0.6);

      final paint = Paint()
        ..color = AppColors.gardenGlow.withValues(alpha: opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, mote.size * 0.8);

      canvas.drawCircle(Offset(x, y), mote.size, paint);

      // Inner bright core
      canvas.drawCircle(
        Offset(x, y),
        mote.size * 0.4,
        Paint()..color = AppColors.white.withValues(alpha: opacity * 0.5),
      );
    }
  }

  @override
  bool shouldRepaint(GardenAmbientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class _DustMote {
  final double baseX;
  final double baseY;
  final double size;
  final double speed;
  final double phase;

  const _DustMote({
    required this.baseX,
    required this.baseY,
    required this.size,
    required this.speed,
    required this.phase,
  });
}
