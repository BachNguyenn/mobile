import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/garden_provider.dart';

class GardenShopItem extends ConsumerWidget {
  final String type;
  final String name;
  final int water;
  final int sun;
  final Offset position;

  const GardenShopItem({
    super.key,
    required this.type,
    required this.name,
    required this.water,
    required this.sun,
    required this.position,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final success = await ref.read(gardenProvider.notifier).buyPlant(type, position.dx - 40, position.dy - 40); // Offset by half size approx
        if (context.mounted) {
          Navigator.pop(context);
          if (!success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không đủ tài nguyên! Hãy học thêm nhé.'),
                backgroundColor: AppColors.terracotta,
              )
            );
          }
        }
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.3)),
              image: DecorationImage(
                image: AssetImage('assets/images/$type.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: AppTypography.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.slateGrey)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.water_drop, size: 12, color: Colors.blue),
              const SizedBox(width: 2),
              Text('$water', style: AppTypography.labelS.copyWith(color: Colors.blue)),
              const SizedBox(width: 8),
              const Icon(Icons.wb_sunny, size: 12, color: Colors.orange),
              const SizedBox(width: 2),
              Text('$sun', style: AppTypography.labelS.copyWith(color: Colors.orange)),
            ],
          ),
        ],
      ),
    );
  }
}
