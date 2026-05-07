import 'package:flutter/material.dart';
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

const gardenShopCatalog = [
  GardenShopCatalogItem(
    type: 'zen_stone',
    name: 'Đá thiền',
    group: 'Đá',
    description: 'Mở đầu khu vườn với một điểm nhấn tĩnh.',
    waterCost: 20,
    sunCost: 10,
    unlockLevel: 1,
    icon: Icons.landscape_rounded,
    color: AppColors.slateGrey,
    assetPath: 'assets/images/zen_stone.webp',
  ),
  GardenShopCatalogItem(
    type: 'zen_bonsai',
    name: 'Bonsai',
    group: 'Cây',
    description: 'Thưởng cho nhịp học đều và bền.',
    waterCost: 50,
    sunCost: 50,
    unlockLevel: 2,
    icon: Icons.park_rounded,
    color: AppColors.mossGreen,
    assetPath: 'assets/images/zen_bonsai.webp',
  ),
  GardenShopCatalogItem(
    type: 'zen_sakura',
    name: 'Hoa đào',
    group: 'Cây',
    description: 'Một góc sáng khi bạn giữ tiến độ tốt.',
    waterCost: 80,
    sunCost: 80,
    unlockLevel: 3,
    icon: Icons.local_florist_rounded,
    color: AppColors.sakura,
    assetPath: 'assets/images/zen_sakura.webp',
  ),
  GardenShopCatalogItem(
    type: 'locked_lantern',
    name: 'Đèn đá',
    group: 'Trang trí',
    description: 'Sắp ra mắt khi vườn đạt cấp cao hơn.',
    waterCost: 120,
    sunCost: 140,
    unlockLevel: 4,
    icon: Icons.light_mode_rounded,
    color: AppColors.sunGold,
  ),
];
