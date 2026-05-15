import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/content/app_content_provider.dart';
import 'package:mobile/core/theme/app_colors.dart';

class GardenShopCatalogItem {
  final String type;
  final String name;
  final String group;
  final String description;
  final int waterCost;
  final int sunCost;
  final int unlockLevel;
  final IconData icon;
  final String? assetPath;
  final Color color;

  const GardenShopCatalogItem({
    required this.type,
    required this.name,
    required this.group,
    required this.description,
    required this.waterCost,
    required this.sunCost,
    required this.unlockLevel,
    required this.icon,
    required this.color,
    this.assetPath,
  });
}

final gardenShopCatalogProvider = FutureProvider<List<GardenShopCatalogItem>>((
  ref,
) async {
  final content = await ref.watch(appContentProvider.future);
  return content.gardenShopCatalog
      .where((item) => item.type.isNotEmpty)
      .map(
        (item) => GardenShopCatalogItem(
          type: item.type,
          name: item.name,
          group: item.group,
          description: item.description,
          waterCost: item.waterCost,
          sunCost: item.sunCost,
          unlockLevel: item.unlockLevel,
          icon: _catalogIcon(item.icon),
          color: _catalogColor(item.color),
          assetPath: item.assetPath,
        ),
      )
      .toList(growable: false);
});

IconData _catalogIcon(String key) {
  return switch (key) {
    'landscape' => Icons.landscape_rounded,
    'park' => Icons.park_rounded,
    'local_florist' => Icons.local_florist_rounded,
    'light_mode' => Icons.light_mode_rounded,
    _ => Icons.spa_rounded,
  };
}

Color _catalogColor(String key) {
  return switch (key) {
    'slateGrey' => AppColors.slateGrey,
    'mossGreen' => AppColors.mossGreen,
    'sakura' => AppColors.sakura,
    'sunGold' => AppColors.sunGold,
    _ => AppColors.leafGreen,
  };
}
