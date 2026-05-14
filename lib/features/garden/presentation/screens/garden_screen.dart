import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/garden/presentation/models/garden_shop_catalog.dart';
import 'package:mobile/features/garden/presentation/providers/garden_mission_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_ambient_painter.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_plant_graphic.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_resource_chip.dart';
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
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.gardenAtmosphere),
            ),
          ),
          _GardenDragSurface(
            garden: garden,
            ambientController: _ambientController,
            onOpenShopAt: (position) => _showShopSheet(context, position),
          ),
          if (garden.plants.isEmpty)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Center(
                  child: _EmptyGardenCard(
                    onOpenShop: () => _showShopSheet(
                      context,
                      Offset(
                        MediaQuery.of(context).size.width / 2,
                        MediaQuery.of(context).size.height / 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            left: AppSpacing.sp16,
            right: AppSpacing.sp16,
            child: _GardenHud(
              garden: garden,
              level: level,
              levelProgress: levelProg,
              missions: missions,
            ),
          ),
          Positioned(
            left: AppSpacing.sp16,
            right: AppSpacing.sp16,
            bottom: AppSpacing.sp24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _MissionPeekCard(missions: missions)),
                const SizedBox(width: AppSpacing.sp12),
                _GardenActionMenu(
                  onShop: () => _showShopSheet(
                    context,
                    Offset(
                      MediaQuery.of(context).size.width / 2,
                      MediaQuery.of(context).size.height / 2,
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
              ],
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

class _GardenHud extends StatelessWidget {
  final ZenGarden garden;
  final int level;
  final double levelProgress;
  final AsyncValue<GardenMissionSummary> missions;

  const _GardenHud({
    required this.garden,
    required this.level,
    required this.levelProgress,
    required this.missions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: _glassDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: CustomPaint(
                  painter: _LevelRingPainter(progress: levelProgress),
                  child: Center(
                    child: Text(
                      '$level',
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.mossGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garden cấp $level',
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                      child: LinearProgressIndicator(
                        value: levelProgress,
                        minHeight: 7,
                        backgroundColor: AppColors.creamDark,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.mossGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              _HudMetric(
                icon: Icons.auto_awesome_rounded,
                value: '${garden.exp}',
                color: AppColors.sunGold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp8),
          missions.when(
            data: (summary) => Row(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 16,
                  color: AppColors.mossGreen,
                ),
                const SizedBox(width: AppSpacing.sp4),
                Expanded(
                  child: Text(
                    '${summary.completedCount}/${summary.missions.length} nhiệm vụ hôm nay',
                    style: AppTypography.label.copyWith(
                      color: AppColors.slateGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${summary.todayStudyCount} lượt học',
                  style: AppTypography.labelS.copyWith(
                    color: AppColors.slateMuted,
                  ),
                ),
              ],
            ),
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, _) => Text(
              'Chưa tải được nhiệm vụ',
              style: AppTypography.labelS.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _HudMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _HudMetric({
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
          Icon(icon, color: color, size: 14),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            value,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionPeekCard extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;

  const _MissionPeekCard({required this.missions});

  @override
  Widget build(BuildContext context) {
    return missions.when(
      data: (summary) {
        final mission = summary.nextMission ?? summary.missions.first;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.sp12),
          decoration: _glassDecoration(),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: mission.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Icon(mission.icon, color: mission.color, size: 19),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mission.isComplete ? 'Nhiệm vụ đã xong' : mission.title,
                      style: AppTypography.label.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                      child: LinearProgressIndicator(
                        value: mission.progress,
                        minHeight: 5,
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
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(height: 60, decoration: _glassDecoration()),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _GardenActionMenu extends StatelessWidget {
  final VoidCallback onShop;
  final VoidCallback onMissions;
  final VoidCallback onLayout;

  const _GardenActionMenu({
    required this.onShop,
    required this.onMissions,
    required this.onLayout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionBubble(
          icon: Icons.storefront_rounded,
          label: 'Shop',
          color: AppColors.mossGreen,
          onTap: onShop,
        ),
        const SizedBox(height: AppSpacing.sp8),
        _ActionBubble(
          icon: Icons.task_alt_rounded,
          label: 'Missions',
          color: AppColors.sunGold,
          onTap: onMissions,
        ),
        const SizedBox(height: AppSpacing.sp8),
        _ActionBubble(
          icon: Icons.open_with_rounded,
          label: 'Layout',
          color: AppColors.waterBlue,
          onTap: onLayout,
        ),
      ],
    );
  }
}

class _ActionBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBubble({
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.90),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color),
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
      width: min(MediaQuery.of(context).size.width - 48, 320.0),
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: _glassDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: AppColors.mossGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            'Bắt đầu khu vườn của bạn',
            style: AppTypography.headingS.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Ôn tập để nhận nước và nắng, rồi đặt vật phẩm đầu tiên vào vườn.',
            style: AppTypography.bodyS.copyWith(color: AppColors.slateGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp16),
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
    final level = gardenLevelForExp(garden.exp);
    final groups = <String>{
      for (final item in gardenShopCatalog) item.group,
    }.toList();

    return _BottomPanel(
      title: 'Shop vườn học tập',
      subtitle: 'Dùng phần thưởng học tập để trang trí vườn.',
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.48,
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: groups.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sp16),
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            final items = gardenShopCatalog
                .where((item) => item.group == group)
                .toList(growable: false);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group,
                  style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.sp8),
                ...items.map(
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
                          image: AssetImage(item.assetPath!),
                          fit: BoxFit.cover,
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
          children: summary.missions
              .map(
                (mission) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                  child: _MissionTile(mission: mission),
                ),
              )
              .toList(),
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
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: mission.color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: mission.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: Icon(mission.icon, color: mission.color),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  mission.subtitle,
                  style: AppTypography.label.copyWith(
                    color: AppColors.slateMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.creamDark,
                    valueColor: AlwaysStoppedAnimation<Color>(mission.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Column(
            children: [
              Icon(
                mission.isComplete
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: mission.isComplete
                    ? AppColors.success
                    : AppColors.slateMuted,
              ),
              const SizedBox(height: AppSpacing.sp4),
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
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        margin: const EdgeInsets.all(AppSpacing.sp16),
        padding: const EdgeInsets.all(AppSpacing.sp20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.10),
              blurRadius: 26,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
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
            const SizedBox(height: AppSpacing.sp16),
            child,
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
    boxShadow: [
      BoxShadow(
        color: AppColors.ink.withValues(alpha: 0.08),
        blurRadius: 22,
        offset: const Offset(0, 10),
      ),
    ],
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

class _LevelRingPainter extends CustomPainter {
  final double progress;

  _LevelRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.mossGreen.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = AppColors.mossGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LevelRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
