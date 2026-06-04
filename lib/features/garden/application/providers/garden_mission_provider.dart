import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/content/app_content_provider.dart';
import 'package:mobile/features/garden/application/providers/garden_provider.dart';
import 'package:mobile/features/review/application/providers/study_event_provider.dart';

class GardenMission {
  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final String colorKey;
  final int current;
  final int target;
  final String rewardText;

  const GardenMission({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorKey,
    required this.current,
    required this.target,
    required this.rewardText,
  });

  bool get isComplete => current >= target;

  double get progress =>
      target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0).toDouble();
}

class GardenMissionSummary {
  final List<GardenMission> missions;
  final int todayStudyCount;
  final int maxCorrectStreak;

  const GardenMissionSummary({
    required this.missions,
    required this.todayStudyCount,
    required this.maxCorrectStreak,
  });

  int get completedCount =>
      missions.where((mission) => mission.isComplete).length;

  GardenMission? get nextMission {
    final open = missions.where((mission) => !mission.isComplete).toList()
      ..sort((a, b) => b.progress.compareTo(a.progress));
    if (open.isEmpty) return null;
    return open.first;
  }

  String get homeHint {
    final mission = nextMission;
    if (mission == null) return 'Hoàn tất nhiệm vụ hôm nay';
    final remaining = (mission.target - mission.current)
        .clamp(0, mission.target)
        .toInt();
    return 'Còn $remaining để xong: ${mission.title.toLowerCase()}';
  }
}

final gardenMissionProvider = FutureProvider<GardenMissionSummary>((ref) async {
  ref.watch(gardenProvider);
  ref.watch(studyEventStreamProvider);

  final repository = ref.watch(gardenRepositoryProvider);
  final content = await ref.watch(appContentProvider.future);
  final todayStudyCount = await repository.getTodayStudyCount();
  final maxCorrectStreak = await repository.getTodayMaxCorrectStreak();

  final lessonProxyProgress = todayStudyCount.clamp(0, 10).toInt();
  final metrics = <String, int>{
    'todayStudyCount': todayStudyCount,
    'maxCorrectStreak': maxCorrectStreak,
    'lessonProxyProgress': lessonProxyProgress,
  };

  return GardenMissionSummary(
    todayStudyCount: todayStudyCount,
    maxCorrectStreak: maxCorrectStreak,
    missions: content.gardenMissions
        .where((mission) => mission.id.isNotEmpty && mission.target > 0)
        .map(
          (mission) => GardenMission(
            id: mission.id,
            title: mission.title,
            subtitle: mission.subtitle,
            iconKey: mission.icon,
            colorKey: mission.color,
            current: (metrics[mission.metric] ?? 0)
                .clamp(0, mission.target)
                .toInt(),
            target: mission.target,
            rewardText: mission.rewardText,
          ),
        )
        .toList(growable: false),
  );
});
