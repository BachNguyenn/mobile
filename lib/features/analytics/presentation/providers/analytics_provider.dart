import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../presentation/providers/home_progress_provider.dart';

class AnalyticsData {
  final int learned;
  final int remembering;
  final int notLearned;
  final List<double> weeklyData;
  final Map<String, double> jlptProgress;

  AnalyticsData({
    required this.learned,
    required this.remembering,
    required this.notLearned,
    required this.weeklyData,
    required this.jlptProgress,
  });
}

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final db = ref.watch(databaseProvider);
  // Watch progress to ensure reactivity
  await ref.watch(homeProgressProvider.future);
  
  final allKanji = await db.select(db.kanjiCardTable).get();
  
  // Stats
  final learned = allKanji.where((c) => c.reps > 0).length;
  final remembering = allKanji.where((c) => c.reps > 0 && c.lapses == 0).length;
  final notLearned = allKanji.where((c) => c.reps == 0).length;

  // Weekly Chart Data (Mocking for now from study logs)
  final studyLogs = await db.select(db.studyLogTable).get();
  final List<double> weekly = List.generate(7, (index) => 0.0);
  final now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
    final log = studyLogs.where((l) => 
      l.date.year == date.year && 
      l.date.month == date.month && 
      l.date.day == date.day
    ).firstOrNull;
    
    if (log != null) {
      weekly[i] = (log.count / 50.0).clamp(0.0, 1.0); // Assume 50 cards is 100%
    }
  }

  // JLPT Distribution
  final Map<String, double> jlpt = {};
  for (int level = 1; level <= 5; level++) {
    final levelCards = allKanji.where((c) => c.jlptLevel == level).toList();
    if (levelCards.isEmpty) {
      jlpt['N$level'] = 0.0;
    } else {
      final learnedCount = levelCards.where((c) => c.reps > 0).length;
      jlpt['N$level'] = learnedCount / levelCards.length;
    }
  }

  return AnalyticsData(
    learned: learned,
    remembering: remembering,
    notLearned: notLearned,
    weeklyData: weekly,
    jlptProgress: jlpt,
  );
});