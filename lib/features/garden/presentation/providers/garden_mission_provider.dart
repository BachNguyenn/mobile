import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/features/review/presentation/providers/study_event_provider.dart';

class GardenMission {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int current;
  final int target;
  final String rewardText;

  const GardenMission({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
  final todayStudyCount = await repository.getTodayStudyCount();
  final maxCorrectStreak = await repository.getTodayMaxCorrectStreak();

  final lessonProxyProgress = todayStudyCount.clamp(0, 10).toInt();

  return GardenMissionSummary(
    todayStudyCount: todayStudyCount,
    maxCorrectStreak: maxCorrectStreak,
    missions: [
      GardenMission(
        id: 'daily_review',
        title: 'Ôn 5 thẻ',
        subtitle: 'Giữ nhịp nhớ bằng một phiên ôn ngắn.',
        icon: Icons.auto_stories_rounded,
        color: AppColors.mossGreen,
        current: todayStudyCount.clamp(0, 5).toInt(),
        target: 5,
        rewardText: '+EXP, nước và nắng',
      ),
      GardenMission(
        id: 'daily_lesson',
        title: 'Hoàn thành 1 bài học',
        subtitle: 'Học đủ một phiên 10 câu để tính như một bài.',
        icon: Icons.route_rounded,
        color: AppColors.waterBlue,
        current: lessonProxyProgress,
        target: 10,
        rewardText: 'Mở khóa tiến trình vườn',
      ),
      GardenMission(
        id: 'correct_streak',
        title: 'Đúng 3 câu liên tiếp',
        subtitle: 'Tập trung để tạo chuỗi trả lời chính xác.',
        icon: Icons.local_fire_department_rounded,
        color: AppColors.terracotta,
        current: maxCorrectStreak.clamp(0, 3).toInt(),
        target: 3,
        rewardText: 'Tăng động lực streak',
      ),
    ],
  );
});
