import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/domain/entities/zen_garden.dart';

/// Animated plant graphic with sway animation, sparkle effects,
/// for the Zen Garden.
class GardenPlantGraphic extends StatefulWidget {
  final Plant plant;
  final ZenGarden garden;
  final bool isDragging;

  const GardenPlantGraphic({
    super.key,
    required this.plant,
    required this.garden,
    this.isDragging = false,
  });

  @override
  State<GardenPlantGraphic> createState() => _GardenPlantGraphicState();
}

class _GardenPlantGraphicState extends State<GardenPlantGraphic>
    with SingleTickerProviderStateMixin {
  AnimationController? _swayController;

  @override
  void initState() {
    super.initState();
    if (_canAnimatePlant(widget.plant)) {
      _swayController = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 2500 + (widget.plant.id.hashCode % 1000),
        ),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _swayController?.dispose();
    super.dispose();
  }

  bool _canAnimatePlant(Plant plant) {
    return plant.type == 'zen_bonsai' ||
        plant.type == 'bonsai' ||
        plant.type == 'zen_sakura' ||
        plant.type == 'flower';
  }

  @override
  Widget build(BuildContext context) {
    String? assetPath;
    double size = 80;

    switch (widget.plant.type) {
      case 'zen_bonsai':
      case 'bonsai':
        assetPath = 'assets/images/zen_bonsai.webp';
        size = 100;
        break;
      case 'zen_sakura':
      case 'flower':
        assetPath = 'assets/images/zen_sakura.webp';
        size = 120;
        break;
      case 'zen_stone':
      case 'stone':
      case 'bamboo':
        assetPath = 'assets/images/zen_stone.webp';
        size = 70;
        break;
    }

    final isWithered = widget.garden.water <= 0 || widget.garden.sunlight <= 0;
    final isStone =
        widget.plant.type == 'zen_stone' ||
        widget.plant.type == 'stone' ||
        widget.plant.type == 'bamboo';

    return SizedBox(
      width: size + 20,
      height: size + 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Plant with sway animation ──────────────────
          _buildAnimatedPlant(assetPath, size, isWithered, isStone),

          // ── Sakura sparkles ────────────────────────────
          if ((widget.plant.type == 'zen_sakura' ||
                  widget.plant.type == 'flower') &&
              !isWithered &&
              !widget.isDragging)
            AnimatedBuilder(
              animation: _swayController!,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(size + 20, size + 20),
                  painter: _SparklePainter(
                    animationValue: _swayController!.value,
                    color: AppColors.petalGlow,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPlant(
    String? assetPath,
    double size,
    bool isWithered,
    bool isStone,
  ) {
    final child = _buildPlantImage(assetPath, size, isWithered);
    final controller = _swayController;
    if (controller == null || isStone || widget.isDragging) return child;

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final swayAngle = sin(controller.value * pi * 2) * 0.02;
        return Transform.rotate(
          angle: swayAngle,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
    );
  }

  Widget _buildPlantImage(String? assetPath, double size, bool isWithered) {
    Widget graphic;
    if (assetPath != null) {
      graphic = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ResizeImage(AssetImage(assetPath), width: size.round() * 2),
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    } else {
      graphic = CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.mossGreen,
        child: const Icon(Icons.park, color: Colors.white),
      );
    }

    if (isWithered) {
      return Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: Opacity(opacity: 0.6, child: graphic),
          ),
          // Droop effect — slight downward tilt
          Transform.rotate(
            angle: 0.05,
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: 0,
              child: SizedBox(width: size, height: size),
            ),
          ),
        ],
      );
    }

    return graphic;
  }
}

/// Sparkle effect painter for sakura plants
class _SparklePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _SparklePainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 4; i++) {
      final phase = i * 0.25;
      final t = (animationValue + phase) % 1.0;
      final opacity = sin(t * pi) * 0.4;

      if (opacity <= 0) continue;

      final seed = (i + 1) * 1.618;
      final x = size.width * (0.25 + (sin(seed) + 1) * 0.25);
      final y = size.height * (0.12 + (cos(seed * 1.7) + 1) * 0.20);
      final dx = sin(t * pi * 2) * 4;
      final dy = t * 8;

      canvas.drawCircle(
        Offset(x + dx, y + dy),
        1.5,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
