import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appContentProvider = FutureProvider<AppContent>((ref) async {
  final jsonString = await rootBundle.loadString(
    'assets/data/app_content.json',
  );
  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  return AppContent.fromJson(decoded);
});

class AppContent {
  final List<String> motivations;
  final List<GardenMissionDefinition> gardenMissions;
  final List<GardenShopCatalogDefinition> gardenShopCatalog;

  const AppContent({
    required this.motivations,
    required this.gardenMissions,
    required this.gardenShopCatalog,
  });

  factory AppContent.fromJson(Map<String, dynamic> json) {
    return AppContent(
      motivations: _stringList(json['motivations']),
      gardenMissions: _mapList(
        json['garden_missions'],
      ).map(GardenMissionDefinition.fromJson).toList(growable: false),
      gardenShopCatalog: _mapList(
        json['garden_shop_catalog'],
      ).map(GardenShopCatalogDefinition.fromJson).toList(growable: false),
    );
  }
}

class GardenMissionDefinition {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String color;
  final String metric;
  final int target;
  final String rewardText;

  const GardenMissionDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.metric,
    required this.target,
    required this.rewardText,
  });

  factory GardenMissionDefinition.fromJson(Map<String, dynamic> json) {
    return GardenMissionDefinition(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      metric: json['metric']?.toString() ?? '',
      target: int.tryParse(json['target']?.toString() ?? '') ?? 0,
      rewardText: json['rewardText']?.toString() ?? '',
    );
  }
}

class GardenShopCatalogDefinition {
  final String type;
  final String name;
  final String group;
  final String description;
  final int waterCost;
  final int sunCost;
  final int unlockLevel;
  final String icon;
  final String color;
  final String? assetPath;

  const GardenShopCatalogDefinition({
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

  factory GardenShopCatalogDefinition.fromJson(Map<String, dynamic> json) {
    final assetPath = json['assetPath']?.toString().trim();
    return GardenShopCatalogDefinition(
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      waterCost: int.tryParse(json['waterCost']?.toString() ?? '') ?? 0,
      sunCost: int.tryParse(json['sunCost']?.toString() ?? '') ?? 0,
      unlockLevel: int.tryParse(json['unlockLevel']?.toString() ?? '') ?? 1,
      icon: json['icon']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      assetPath: assetPath == null || assetPath.isEmpty ? null : assetPath,
    );
  }
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
