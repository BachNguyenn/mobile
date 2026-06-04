import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/garden/application/providers/garden_mission_provider.dart';
import 'package:mobile/features/garden/application/providers/garden_provider.dart';
import 'package:mobile/features/garden/presentation/models/garden_mission_style.dart';
import 'package:mobile/features/garden/presentation/models/garden_shop_catalog.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_ambient_painter.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_plant_graphic.dart';
import 'package:mobile/features/garden/presentation/widgets/sand_rake_painter.dart';

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

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);
    final missions = ref.watch(gardenMissionProvider);
    final level = gardenLevelForExp(garden.exp);
    final levelProg = gardenLevelProgress(garden.exp);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.gardenSand,
      appBar: AppBar(
        title: Text(
          'Khu vườn Zen',
          style: AppTypography.headingM.copyWith(color: AppColors.navyDark),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          _ResourcePill(
            icon: Icons.water_drop_rounded,
            value: garden.water.toString(),
            color: AppColors.waterBlue,
          ),
          const SizedBox(width: AppSpacing.sp8),
          _ResourcePill(
            icon: Icons.wb_sunny_rounded,
            value: garden.sunlight.toString(),
            color: AppColors.sunGold,
          ),
          const SizedBox(width: AppSpacing.sp16),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.gardenAtmosphere),
            ),
          ),
          Positioned.fill(
            child: _GardenDragSurface(
              garden: garden,
              ambientController: _ambientController,
              onOpenShopAt: (position) => _showShopSheet(context, position),
            ),
          ),
          if (garden.plants.isEmpty)
            Positioned(
              left: AppSpacing.sp16,
              right: AppSpacing.sp16,
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 164,
              child: _EmptyGardenCard(
                onOpenShop: () => _showShopSheet(
                  context,
                  Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height * 0.46,
                  ),
                ),
              ),
            ),
          Positioned(
            left: AppSpacing.sp16,
            right: AppSpacing.sp16,
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            child: _GardenOverviewCard(
              garden: garden,
              level: level,
              levelProgress: levelProg,
              missions: missions,
            ),
          ),
          Positioned(
            left: AppSpacing.sp16,
            right: AppSpacing.sp16,
            bottom: AppSpacing.sp16,
            child: SafeArea(
              top: false,
              child: _GardenOverlayDock(
                missions: missions,
                onShop: () => _showShopSheet(
                  context,
                  Offset(
                    MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height * 0.54,
                  ),
                ),
                onMissions: () => _showMissionSheet(context, missions),
                onLayout: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kéo vật phẩm trong vườn để sắp xếp.'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showShopSheet(BuildContext context, Offset position) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShopSheet(position: position),
    );
  }

  void _showMissionSheet(
    BuildContext context,
    AsyncValue<GardenMissionSummary> missions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MissionSheet(missions: missions),
    );
  }
}

class _GardenDragSurface extends ConsumerWidget {
  final ZenGarden garden;
  final AnimationController ambientController;
  final ValueChanged<Offset> onOpenShopAt;

  const _GardenDragSurface({
    required this.garden,
    required this.ambientController,
    required this.onOpenShopAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(
      builder: (context) {
        return DragTarget<Plant>(
          onAcceptWithDetails: (details) {
            final renderBox = context.findRenderObject() as RenderBox;
            final localOffset = renderBox.globalToLocal(details.offset);
            final plant = details.data;
            final dx = localOffset.dx - plant.x;
            final dy = localOffset.dy - plant.y;
            ref
                .read(gardenProvider.notifier)
                .updatePlantPosition(plant.id, dx, dy);
          },
          builder: (context, candidateData, rejectedData) {
            final stonePositions = garden.plants
                .map((plant) => Offset(plant.x + 40, plant.y + 40))
                .toList();

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) => onOpenShopAt(details.localPosition),
                    child: CustomPaint(
                      painter: SandRakePainter(stonePositions: stonePositions),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _GardenSceneryPainter()),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: ambientController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: GardenAmbientPainter(
                            animationValue: ambientController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
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
                        child: GardenPlantGraphic(plant: plant, garden: garden),
                      ),
                      child: GardenPlantGraphic(plant: plant, garden: garden),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _GardenSceneryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawSoftGroundPatches(canvas, size);
    _drawBackHedge(canvas, size);
    _drawBambooFence(canvas, size);
    _drawTeaHouse(canvas, size);
    _drawSteppingStones(canvas, size);
    _drawPond(canvas, size);
    _drawStoneLantern(canvas, size);
    _drawShrubs(canvas, size);
  }

  void _drawSoftGroundPatches(Canvas canvas, Size size) {
    final grassPaint = Paint()
      ..color = AppColors.leafGreen.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.25, size.height * 0.86),
        width: size.width * 0.55,
        height: size.height * 0.22,
      ),
      grassPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.78, size.height * 0.22),
        width: size.width * 0.42,
        height: size.height * 0.18,
      ),
      grassPaint..color = AppColors.leafLight.withValues(alpha: 0.09),
    );
  }

  void _drawBackHedge(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = AppColors.leafDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final leafPaint = Paint()
      ..color = AppColors.leafGreen.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final lightLeafPaint = Paint()
      ..color = AppColors.leafLight.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final x = size.width * (-0.04 + i * 0.15);
      final y = size.height * (0.05 + (i.isEven ? 0.02 : 0.0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 18, y + 26, 8, 36),
          const Radius.circular(8),
        ),
        trunkPaint,
      );
      canvas.drawCircle(Offset(x + 24, y + 20), 24, leafPaint);
      canvas.drawCircle(Offset(x + 8, y + 32), 19, lightLeafPaint);
      canvas.drawCircle(Offset(x + 42, y + 34), 20, leafPaint);
    }
  }

  void _drawBambooFence(Canvas canvas, Size size) {
    final railPaint = Paint()
      ..color = AppColors.leafDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final postPaint = Paint()
      ..color = AppColors.leafDark.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final y = size.height * 0.18;
    canvas.drawLine(Offset(18, y), Offset(size.width - 18, y - 10), railPaint);
    canvas.drawLine(
      Offset(18, y + 12),
      Offset(size.width - 18, y + 2),
      railPaint,
    );

    for (var x = 30.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, y - 16), Offset(x, y + 28), postPaint);
    }
  }

  void _drawTeaHouse(Canvas canvas, Size size) {
    final houseWidth = min(size.width * 0.34, 132.0);
    final houseHeight = houseWidth * 0.62;
    final left = size.width - houseWidth - 24;
    final top = size.height * 0.22;

    final shadowPaint = Paint()
      ..color = AppColors.navyDark.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + 4, top + houseHeight - 6, houseWidth - 8, 16),
        const Radius.circular(16),
      ),
      shadowPaint,
    );

    final bodyRect = Rect.fromLTWH(
      left + houseWidth * 0.12,
      top + houseHeight * 0.35,
      houseWidth * 0.76,
      houseHeight * 0.54,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()..color = AppColors.white.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(8)),
      Paint()
        ..color = AppColors.navy.withValues(alpha: 0.10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final roof = Path()
      ..moveTo(left, top + houseHeight * 0.38)
      ..lineTo(left + houseWidth * 0.50, top)
      ..lineTo(left + houseWidth, top + houseHeight * 0.38)
      ..lineTo(left + houseWidth * 0.86, top + houseHeight * 0.48)
      ..lineTo(left + houseWidth * 0.50, top + houseHeight * 0.18)
      ..lineTo(left + houseWidth * 0.14, top + houseHeight * 0.48)
      ..close();
    canvas.drawPath(
      roof,
      Paint()..color = AppColors.navy.withValues(alpha: 0.78),
    );

    final doorRect = Rect.fromLTWH(
      left + houseWidth * 0.43,
      top + houseHeight * 0.54,
      houseWidth * 0.16,
      houseHeight * 0.35,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(doorRect, const Radius.circular(4)),
      Paint()..color = AppColors.leafDark.withValues(alpha: 0.38),
    );

    final windowPaint = Paint()
      ..color = AppColors.sunGold.withValues(alpha: 0.26)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + houseWidth * 0.21,
          top + houseHeight * 0.56,
          houseWidth * 0.16,
          houseHeight * 0.16,
        ),
        const Radius.circular(4),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + houseWidth * 0.63,
          top + houseHeight * 0.56,
          houseWidth * 0.16,
          houseHeight * 0.16,
        ),
        const Radius.circular(4),
      ),
      windowPaint,
    );
  }

  void _drawSteppingStones(Canvas canvas, Size size) {
    final stonePaint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final highlightPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    final points = <Offset>[
      Offset(size.width * 0.24, size.height * 0.86),
      Offset(size.width * 0.34, size.height * 0.76),
      Offset(size.width * 0.45, size.height * 0.66),
      Offset(size.width * 0.57, size.height * 0.56),
      Offset(size.width * 0.68, size.height * 0.48),
    ];

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final width = 30.0 + (i.isEven ? 8 : 0);
      canvas.drawOval(
        Rect.fromCenter(center: point, width: width, height: 17),
        stonePaint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: point.translate(-4, -3),
          width: width * 0.38,
          height: 5,
        ),
        highlightPaint,
      );
    }
  }

  void _drawPond(Canvas canvas, Size size) {
    final pondRect = Rect.fromCenter(
      center: Offset(size.width * 0.78, size.height * 0.78),
      width: min(size.width * 0.34, 132.0),
      height: 72,
    );
    final borderPaint = Paint()
      ..color = AppColors.leafDark.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawOval(pondRect.inflate(7), borderPaint);

    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.waterBlue.withValues(alpha: 0.34),
          AppColors.waterBlue.withValues(alpha: 0.14),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(pondRect);
    canvas.drawOval(pondRect, waterPaint);

    final ripplePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(pondRect.deflate(18), 0.2, 2.2, false, ripplePaint);
    canvas.drawArc(pondRect.deflate(30), 3.4, 1.6, false, ripplePaint);

    final lilyPaint = Paint()
      ..color = AppColors.leafGreen.withValues(alpha: 0.36)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: pondRect.center.translate(-26, 2),
        width: 18,
        height: 10,
      ),
      lilyPaint,
    );
    canvas.drawCircle(
      pondRect.center.translate(-20, -5),
      3,
      Paint()..color = AppColors.sakura.withValues(alpha: 0.55),
    );
  }

  void _drawStoneLantern(Canvas canvas, Size size) {
    final x = size.width * 0.16;
    final y = size.height * 0.53;
    final paint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;
    final lightPaint = Paint()
      ..color = AppColors.sunGold.withValues(alpha: 0.26)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 62), width: 42, height: 13),
      Paint()..color = AppColors.navyDark.withValues(alpha: 0.07),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 5, y + 24, 10, 36),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 17, y + 14, 34, 18),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 10, y + 18, 20, 9),
        const Radius.circular(4),
      ),
      lightPaint,
    );
    final cap = Path()
      ..moveTo(x - 24, y + 14)
      ..lineTo(x, y - 4)
      ..lineTo(x + 24, y + 14)
      ..close();
    canvas.drawPath(cap, paint);
  }

  void _drawShrubs(Canvas canvas, Size size) {
    final shrubPaint = Paint()
      ..color = AppColors.leafGreen.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final shrubLightPaint = Paint()
      ..color = AppColors.leafLight.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    void shrub(Offset center, double scale) {
      canvas.drawCircle(
        center.translate(-12 * scale, 2),
        13 * scale,
        shrubPaint,
      );
      canvas.drawCircle(
        center.translate(0, -5 * scale),
        17 * scale,
        shrubLightPaint,
      );
      canvas.drawCircle(
        center.translate(15 * scale, 3),
        14 * scale,
        shrubPaint,
      );
    }

    shrub(Offset(size.width * 0.13, size.height * 0.82), 1.0);
    shrub(Offset(size.width * 0.88, size.height * 0.43), 0.82);
    shrub(Offset(size.width * 0.43, size.height * 0.24), 0.72);
  }

  @override
  bool shouldRepaint(covariant _GardenSceneryPainter oldDelegate) => false;
}

class _ResourcePill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _ResourcePill({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            value,
            style: AppTypography.label.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenOverviewCard extends StatelessWidget {
  final ZenGarden garden;
  final int level;
  final double levelProgress;
  final AsyncValue<GardenMissionSummary> missions;

  const _GardenOverviewCard({
    required this.garden,
    required this.level,
    required this.levelProgress,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: _glassDecoration().copyWith(
        color: AppColors.white.withValues(alpha: 0.84),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.64)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.brandLeafGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: Center(
              child: Text(
                '$level',
                style: AppTypography.bodyMBold.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Vườn cấp $level',
                        style: AppTypography.bodyMBold.copyWith(
                          color: AppColors.navyDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${garden.exp} exp',
                      style: AppTypography.labelS.copyWith(
                        color: AppColors.leafDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.creamDark,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.leafGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                missions.when(
                  data: (summary) => Text(
                    '${summary.completedCount}/${summary.missions.length} nhiệm vụ hôm nay',
                    style: AppTypography.labelS.copyWith(
                      color: AppColors.slateMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  loading: () => Text(
                    'Đang tải nhiệm vụ...',
                    style: AppTypography.labelS.copyWith(
                      color: AppColors.slateMuted,
                    ),
                  ),
                  error: (_, _) => Text(
                    'Chưa tải được nhiệm vụ',
                    style: AppTypography.labelS.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GardenOverlayDock extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;
  final VoidCallback onShop;
  final VoidCallback onMissions;
  final VoidCallback onLayout;

  const _GardenOverlayDock({
    required this.missions,
    required this.onShop,
    required this.onMissions,
    required this.onLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _CompactMissionStrip(missions: missions, onTap: onMissions),
        ),
        const SizedBox(width: AppSpacing.sp12),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GardenActionBubble(
              icon: Icons.storefront_rounded,
              label: 'Shop',
              color: AppColors.leafGreen,
              onTap: onShop,
            ),
            const SizedBox(height: AppSpacing.sp8),
            _GardenActionBubble(
              icon: Icons.task_alt_rounded,
              label: 'Nhiệm vụ',
              color: AppColors.navy,
              onTap: onMissions,
            ),
            const SizedBox(height: AppSpacing.sp8),
            _GardenActionBubble(
              icon: Icons.open_with_rounded,
              label: 'Sắp xếp',
              color: AppColors.waterBlue,
              onTap: onLayout,
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactMissionStrip extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;
  final VoidCallback onTap;

  const _CompactMissionStrip({required this.missions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return missions.when(
      data: (summary) {
        final mission = summary.nextMission ?? summary.missions.first;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp12,
                vertical: AppSpacing.sp8,
              ),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.62),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: mission.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(mission.icon, color: mission.color, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mission.isComplete
                              ? 'Nhiệm vụ đã xong'
                              : mission.title,
                          style: AppTypography.label.copyWith(
                            color: AppColors.navyDark,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sp4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXL,
                          ),
                          child: LinearProgressIndicator(
                            value: mission.progress,
                            minHeight: 4,
                            backgroundColor: AppColors.creamDark,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              mission.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Text(
                    '${mission.current}/${mission.target}',
                    style: AppTypography.labelS.copyWith(
                      color: mission.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 32,
        child: Center(
          child: LinearProgressIndicator(
            minHeight: 3,
            color: AppColors.leafGreen,
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _GardenActionBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GardenActionBubble({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.86),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Center(child: Icon(icon, color: color, size: 22)),
          ),
        ),
      ),
    );
  }
}

class _EmptyGardenCard extends StatelessWidget {
  final VoidCallback onOpenShop;

  const _EmptyGardenCard({required this.onOpenShop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: min(MediaQuery.of(context).size.width - 72, 270.0),
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: _glassDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: AppColors.mossGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Bắt đầu khu vườn của bạn',
            style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            'Chạm nền hoặc mở shop để đặt vật phẩm.',
            style: AppTypography.label.copyWith(color: AppColors.slateGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp8),
          FilledButton.icon(
            onPressed: onOpenShop,
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: const Text('Mở shop'),
          ),
        ],
      ),
    );
  }
}

class _ShopSheet extends ConsumerWidget {
  final Offset position;

  const _ShopSheet({required this.position});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);
    final catalog = ref.watch(gardenShopCatalogProvider);
    final level = gardenLevelForExp(garden.exp);

    return _BottomPanel(
      title: 'Shop vườn học tập',
      subtitle: 'Dùng phần thưởng học tập để trang trí vườn.',
      child: catalog.when(
        data: (items) {
          final groups = <String>{
            for (final item in items) item.group,
          }.toList();
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.48,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: groups.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sp16),
              itemBuilder: (context, groupIndex) {
                final group = groups[groupIndex];
                final groupItems = items
                    .where((item) => item.group == group)
                    .toList(growable: false);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group,
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    ...groupItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                        child: _ShopCatalogTile(
                          item: item,
                          garden: garden,
                          level: level,
                          onBuy: () async {
                            final success = await ref
                                .read(gardenProvider.notifier)
                                .buyPlant(
                                  item.type,
                                  position.dx - 40,
                                  position.dy - 40,
                                  waterCost: item.waterCost,
                                  sunCost: item.sunCost,
                                );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Đã đặt ${item.name} vào vườn.'
                                      : 'Chưa đủ tài nguyên. Học thêm một chút nhé.',
                                ),
                                backgroundColor: success
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.sp24),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.mossGreen),
          ),
        ),
        error: (_, _) => Text(
          'Chưa tải được shop.',
          style: AppTypography.bodyM.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ShopCatalogTile extends StatelessWidget {
  final GardenShopCatalogItem item;
  final ZenGarden garden;
  final int level;
  final VoidCallback onBuy;

  const _ShopCatalogTile({
    required this.item,
    required this.garden,
    required this.level,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = level >= item.unlockLevel;
    final hasAsset = item.assetPath != null;
    final canAfford =
        garden.water >= item.waterCost && garden.sunlight >= item.sunCost;
    final canBuy = isUnlocked && canAfford && hasAsset;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canBuy ? onBuy : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp12),
          decoration: BoxDecoration(
            color: canBuy
                ? AppColors.white
                : AppColors.creamDark.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: item.color.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                  image: item.assetPath == null
                      ? null
                      : DecorationImage(
                          image: ResizeImage(
                            AssetImage(item.assetPath!),
                            width: 112,
                          ),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                ),
                child: item.assetPath == null
                    ? Icon(item.icon, color: item.color)
                    : null,
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTypography.bodyMBold.copyWith(
                              color: isUnlocked
                                  ? AppColors.ink
                                  : AppColors.slateMuted,
                            ),
                          ),
                        ),
                        if (!isUnlocked)
                          _SmallLockBadge(text: 'Cấp ${item.unlockLevel}')
                        else if (!hasAsset)
                          const _SmallLockBadge(text: 'Sắp có'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Text(
                      item.description,
                      style: AppTypography.label.copyWith(
                        color: AppColors.slateMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Row(
                      children: [
                        _CostChip(
                          icon: Icons.water_drop_rounded,
                          value: item.waterCost.toString(),
                          color: AppColors.waterBlue,
                          isEnough: garden.water >= item.waterCost,
                        ),
                        const SizedBox(width: AppSpacing.sp8),
                        _CostChip(
                          icon: Icons.wb_sunny_rounded,
                          value: item.sunCost.toString(),
                          color: AppColors.sunGold,
                          isEnough: garden.sunlight >= item.sunCost,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Icon(
                canBuy ? Icons.add_circle_rounded : Icons.lock_rounded,
                color: canBuy ? item.color : AppColors.slateMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionSheet extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;

  const _MissionSheet({required this.missions});

  @override
  Widget build(BuildContext context) {
    return _BottomPanel(
      title: 'Nhiệm vụ hôm nay',
      subtitle: 'Hoàn thành nhiệm vụ để khu vườn lớn lên cùng việc học.',
      child: missions.when(
        data: (summary) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < summary.missions.length; index++) ...[
              _MissionTile(mission: summary.missions[index]),
              if (index != summary.missions.length - 1)
                const SizedBox(height: AppSpacing.sp8),
            ],
          ],
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.sp24),
          child: CircularProgressIndicator(color: AppColors.mossGreen),
        ),
        error: (_, _) => Text(
          'Chưa tải được nhiệm vụ.',
          style: AppTypography.bodyM.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}

class _MissionTile extends StatelessWidget {
  final GardenMission mission;

  const _MissionTile({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: mission.color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: mission.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            ),
            child: Icon(mission.icon, color: mission.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mission.title,
                  style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  mission.subtitle,
                  style: AppTypography.labelS.copyWith(
                    color: AppColors.slateMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    minHeight: 5,
                    backgroundColor: AppColors.creamDark,
                    valueColor: AlwaysStoppedAnimation<Color>(mission.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mission.isComplete
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: mission.isComplete
                    ? AppColors.success
                    : AppColors.slateMuted,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                '${mission.current}/${mission.target}',
                style: AppTypography.labelS.copyWith(
                  color: mission.color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _BottomPanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.sp12,
          AppSpacing.sp12,
          AppSpacing.sp12,
          AppSpacing.sp24,
        ),
        padding: const EdgeInsets.all(AppSpacing.sp16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          border: Border.all(
            color: AppColors.slateLight.withValues(alpha: 0.22),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
                decoration: BoxDecoration(
                  color: AppColors.slateLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: AppTypography.headingM.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Text(
              subtitle,
              style: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
            ),
            const SizedBox(height: AppSpacing.sp12),
            Flexible(fit: FlexFit.loose, child: child),
          ],
        ),
      ),
    );
  }
}

class _CostChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final bool isEnough;

  const _CostChip({
    required this.icon,
    required this.value,
    required this.color,
    required this.isEnough,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isEnough ? color : AppColors.slateMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: chipColor, size: 13),
        const SizedBox(width: 2),
        Text(
          value,
          style: AppTypography.labelS.copyWith(
            color: chipColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SmallLockBadge extends StatelessWidget {
  final String text;

  const _SmallLockBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.slateMuted.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        text,
        style: AppTypography.labelS.copyWith(
          color: AppColors.slateMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

BoxDecoration _glassDecoration() {
  return BoxDecoration(
    color: AppColors.white.withValues(alpha: 0.84),
    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
    border: Border.all(color: AppColors.white.withValues(alpha: 0.50)),
  );
}

int gardenLevelForExp(int exp) {
  if (exp >= 500) return 5;
  if (exp >= 300) return 4;
  if (exp >= 150) return 3;
  if (exp >= 50) return 2;
  return 1;
}

double gardenLevelProgress(int exp) {
  const thresholds = [0, 50, 150, 300, 500];
  final level = gardenLevelForExp(exp);
  if (level >= 5) return 1.0;
  final current = exp - thresholds[level - 1];
  final needed = thresholds[level] - thresholds[level - 1];
  return (current / needed).clamp(0.0, 1.0).toDouble();
}
