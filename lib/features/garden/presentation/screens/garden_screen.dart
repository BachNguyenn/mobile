import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/garden/presentation/widgets/sand_rake_painter.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_ambient_painter.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_resource_chip.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_plant_graphic.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_shop_item.dart';

class GardenScreen extends ConsumerStatefulWidget {
  const GardenScreen({super.key});

  @override
  ConsumerState<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends ConsumerState<GardenScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    super.dispose();
  }

  int _gardenLevel(int exp) {
    if (exp >= 500) return 5;
    if (exp >= 300) return 4;
    if (exp >= 150) return 3;
    if (exp >= 50) return 2;
    return 1;
  }

  double _levelProgress(int exp) {
    const thresholds = [0, 50, 150, 300, 500];
    final level = _gardenLevel(exp);
    if (level >= 5) return 1.0;
    final current = exp - thresholds[level - 1];
    final needed = thresholds[level] - thresholds[level - 1];
    return (current / needed).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);
    final level = _gardenLevel(garden.exp);
    final levelProg = _levelProgress(garden.exp);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Khu vườn Zen',
          style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
        ),
        backgroundColor: AppColors.glassBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          GardenResourceChip(
            icon: Icons.water_drop,
            value: garden.water.toString(),
            color: AppColors.waterBlue,
          ),
          GardenResourceChip(
            icon: Icons.wb_sunny,
            value: garden.sunlight.toString(),
            color: AppColors.sunGold,
          ),
          const SizedBox(width: AppSpacing.sp12),
        ],
      ),
      body: Stack(
        children: [
          // ── Full-bleed atmospheric gradient ──────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.gardenAtmosphere,
              ),
            ),
          ),

          // ── Garden Area (Drag Target) ────────────────────
          Builder(
            builder: (context) {
              return DragTarget<Plant>(
                onAcceptWithDetails: (details) {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final localOffset =
                      renderBox.globalToLocal(details.offset);
                  final plant = details.data;
                  final dx = localOffset.dx - plant.x;
                  final dy = localOffset.dy - plant.y;
                  ref
                      .read(gardenProvider.notifier)
                      .updatePlantPosition(plant.id, dx, dy);
                },
                builder: (context, candidateData, rejectedData) {
                  // Compute stone positions for sand painter
                  final stonePositions = garden.plants
                      .map((p) => Offset(p.x + 40, p.y + 40))
                      .toList();

                  return Stack(
                    children: [
                      // ── Sand Ground ──────────────────────
                      Positioned.fill(
                        child: GestureDetector(
                          onTapDown: (details) {
                            _showPlacementMenu(
                              context,
                              ref,
                              details.localPosition,
                            );
                          },
                          child: CustomPaint(
                            painter: SandRakePainter(
                              stonePositions: stonePositions,
                            ),
                          ),
                        ),
                      ),

                      // ── Ambient Effects ──────────────────
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _ambientController,
                            builder: (context, _) {
                              return CustomPaint(
                                painter: GardenAmbientPainter(
                                  animationValue: _ambientController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // ── Plants / Objects ──────────────────
                      ...garden.plants.map(
                        (plant) => Positioned(
                          left: plant.x,
                          top: plant.y,
                          child: Draggable<Plant>(
                            data: plant,
                            feedback: GardenPlantGraphic(
                              plant: plant,
                              garden: garden,
                              isDragging: true,
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.2,
                              child: GardenPlantGraphic(
                                plant: plant,
                                garden: garden,
                              ),
                            ),
                            child: GardenPlantGraphic(
                              plant: plant,
                              garden: garden,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // ── Garden Level Indicator ──────────────────────
          Positioned(
            bottom: 100,
            left: AppSpacing.sp24,
            child: _GardenLevelBadge(
              level: level,
              progress: levelProg,
              exp: garden.exp,
            ),
          ),

          // ── Shop FAB — wooden sign style ─────────────────
          Positioned(
            bottom: AppSpacing.sp32,
            right: AppSpacing.sp24,
            child: _ShopFAB(
              onTap: () => _showPlacementMenu(
                context,
                ref,
                Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlacementMenu(
    BuildContext context,
    WidgetRef ref,
    Offset position,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.sp16),
          padding: const EdgeInsets.all(AppSpacing.sp24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
                decoration: BoxDecoration(
                  color: AppColors.slateLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Cửa hàng Thiền',
                style: AppTypography.headingM
                    .copyWith(color: AppColors.slateGrey),
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                'Dùng tài nguyên học tập để trang trí vườn',
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.slateMuted),
              ),
              const SizedBox(height: AppSpacing.sp24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GardenShopItem(
                    type: 'zen_bonsai',
                    name: 'Bonsai',
                    water: 50,
                    sun: 50,
                    position: position,
                  ),
                  GardenShopItem(
                    type: 'zen_sakura',
                    name: 'Hoa Đào',
                    water: 80,
                    sun: 80,
                    position: position,
                  ),
                  GardenShopItem(
                    type: 'zen_stone',
                    name: 'Đá Cảnh',
                    water: 20,
                    sun: 10,
                    position: position,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp24),
            ],
          ),
        );
      },
    );
  }
}

/// Garden level indicator badge with progress ring
class _GardenLevelBadge extends StatelessWidget {
  final int level;
  final double progress;
  final int exp;

  const _GardenLevelBadge({
    required this.level,
    required this.progress,
    required this.exp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.glassStroke),
        boxShadow: [
          BoxShadow(
            color: AppColors.glassShadow,
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Level ring
          SizedBox(
            width: 32,
            height: 32,
            child: CustomPaint(
              painter: _LevelRingPainter(progress: progress),
              child: Center(
                child: Text(
                  '$level',
                  style: AppTypography.label.copyWith(
                    color: AppColors.mossGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cấp $level',
                style: AppTypography.labelS.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$exp EXP',
                style: AppTypography.labelS.copyWith(
                  color: AppColors.slateMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelRingPainter extends CustomPainter {
  final double progress;

  _LevelRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Background ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.mossGreen.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Progress arc
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = AppColors.mossGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LevelRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Floating action button styled as a wooden shop sign
class _ShopFAB extends StatefulWidget {
  final VoidCallback onTap;

  const _ShopFAB({required this.onTap});

  @override
  State<_ShopFAB> createState() => _ShopFABState();
}

class _ShopFABState extends State<_ShopFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final bounce = sin(_bounceController.value * pi) * 3;
        return Transform.translate(
          offset: Offset(0, -bounce),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.mossGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.mossGreen.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '木',
              style: AppTypography.headingM.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
