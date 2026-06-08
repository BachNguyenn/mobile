import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/garden/application/providers/garden_mission_provider.dart';
import 'package:mobile/features/garden/presentation/models/garden_mission_style.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class MissionCard extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;
  final VoidCallback onTap;

  const MissionCard({
    super.key,
    required this.missions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return missions.when(
      data: (summary) {
        final resolvedLeafGreen = AppColors.resolve(
          AppColors.leafGreen,
          context,
        );
        return AppCard(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp12,
            AppSpacing.sp16,
            AppSpacing.sp12,
          ),
          borderColor: resolvedLeafGreen.withValues(alpha: 0.14),
          shadowColor: resolvedLeafGreen.withValues(alpha: 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nhiệm vụ hôm nay',
                    style: AppTypography.headingS.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${summary.completedCount}/${summary.missions.length}',
                    style: AppTypography.label.copyWith(
                      color: resolvedLeafGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              ...summary.missions.map((mission) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                  child: _MissionRow(mission: mission),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const AppCard(child: SizedBox(height: 84)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final GardenMission mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(mission.color, context);
    return Row(
      children: [
        Icon(mission.icon, color: resolvedColor, size: 21),
        const SizedBox(width: AppSpacing.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Text(
                    '${mission.current}/${mission.target}',
                    style: AppTypography.label.copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: mission.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.resolve(
                    AppColors.creamDark,
                    context,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
