import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/garden/application/providers/garden_mission_provider.dart';

extension GardenMissionStyle on GardenMission {
  IconData get icon {
    return switch (iconKey) {
      'auto_stories' => Icons.auto_stories_rounded,
      'route' => Icons.route_rounded,
      'local_fire_department' => Icons.local_fire_department_rounded,
      _ => Icons.flag_rounded,
    };
  }

  Color get color {
    return switch (colorKey) {
      'mossGreen' => AppColors.mossGreen,
      'waterBlue' => AppColors.waterBlue,
      'terracotta' => AppColors.terracotta,
      _ => AppColors.leafGreen,
    };
  }
}
