import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/garden/presentation/widgets/sand_rake_painter.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_resource_chip.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_plant_graphic.dart';
import 'package:mobile/features/garden/presentation/widgets/garden_shop_item.dart';

class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);

    return Scaffold(
      backgroundColor: AppColors.cream, // Sand/Paper color
      appBar: AppBar(
        title: Text('Khu vườn Zen', style: AppTypography.headingM.copyWith(color: AppColors.slateGrey)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          GardenResourceChip(icon: Icons.water_drop, value: garden.water.toString(), color: Colors.blue),
          GardenResourceChip(icon: Icons.wb_sunny, value: garden.sunlight.toString(), color: Colors.orange),
          const SizedBox(width: 16),
        ],
      ),
      body: Builder(
        builder: (context) {
          return DragTarget<Plant>(
            onAcceptWithDetails: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localOffset = renderBox.globalToLocal(details.offset);
              final plant = details.data;
              final dx = localOffset.dx - plant.x;
              final dy = localOffset.dy - plant.y;
              ref.read(gardenProvider.notifier).updatePlantPosition(plant.id, dx, dy);
            },
            builder: (context, candidateData, rejectedData) {
              return Stack(
                children: [
                  // The Sand Ground
                  Positioned.fill(
                    child: GestureDetector(
                      onTapDown: (details) {
                        _showPlacementMenu(context, ref, details.localPosition);
                      },
                      child: CustomPaint(
                        painter: SandRakePainter(),
                      ),
                    ),
                  ),
                  
                  // The Plants/Objects
                  ...garden.plants.map((plant) => Positioned(
                    left: plant.x,
                    top: plant.y,
                    child: Draggable<Plant>(
                      data: plant,
                      feedback: GardenPlantGraphic(plant: plant, garden: garden, isDragging: true),
                      childWhenDragging: Opacity(opacity: 0.3, child: GardenPlantGraphic(plant: plant, garden: garden)),
                      child: GardenPlantGraphic(plant: plant, garden: garden),
                    ),
                  )),
                ],
              );
            },
          );
        }
      ),
    );
  }

  void _showPlacementMenu(BuildContext context, WidgetRef ref, Offset position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cửa hàng Thiền', style: AppTypography.headingM.copyWith(color: AppColors.slateGrey)),
              const SizedBox(height: 8),
              Text('Dùng tài nguyên học tập để trang trí vườn', 
                  style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GardenShopItem(type: 'zen_bonsai', name: 'Bonsai', water: 50, sun: 50, position: position),
                  GardenShopItem(type: 'zen_sakura', name: 'Hoa Đào', water: 80, sun: 80, position: position),
                  GardenShopItem(type: 'zen_stone', name: 'Đá Cảnh', water: 20, sun: 10, position: position),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
