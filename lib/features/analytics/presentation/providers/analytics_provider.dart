import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';

class AnalyticsData {
  final int learned;
  final int remembering;
  final int notLearned;
  final Map<DateTime, int> heatmapData;
  final Map<String, double> jlptProgress;
  final int reviewsLast30Days;
  final int activeDaysLast30Days;
  final double successRateLast30Days;
  final String weakestArea;
  final String? weakestAreaType;
  final double weakestAreaSuccessRate;
  final double d1Retention;
  final double d7Retention;
  final double lessonCompletionRate;
  final String dropoutPoint;
  final Map<String, double> cohortByLevel;

  AnalyticsData({
    required this.learned,
    required this.remembering,
    required this.notLearned,
    required this.heatmapData,
    required this.jlptProgress,
    required this.reviewsLast30Days,
    required this.activeDaysLast30Days,
    required this.successRateLast30Days,
    required this.weakestArea,
    required this.weakestAreaType,
    required this.weakestAreaSuccessRate,
    required this.d1Retention,
    required this.d7Retention,
    required this.lessonCompletionRate,
    required this.dropoutPoint,
    required this.cohortByLevel,
  });
}

final analyticsProvider = FutureProvider<AnalyticsData>((ref) async {
  final db = ref.watch(databaseProvider);
  // Watch progress to ensure reactivity
  await ref.watch(homeProgressProvider.future);

  final allKanji = await db.select(db.kanjiCardTable).get();
  final allVocab = await db.select(db.vocabularyTable).get();
  final allGrammar = await db.select(db.grammarTable).get();

  // Stats (combined across Kanji, Vocabulary, Grammar)
  final learnedKanji = allKanji.where((c) => c.reps > 0).length;
  final learnedVocab = allVocab.where((c) => c.reps > 0).length;
  final learnedGrammar = allGrammar.where((c) => c.isLearned).length;
  final learned = learnedKanji + learnedVocab + learnedGrammar;

  final rememberingKanji = allKanji
      .where((c) => c.reps > 0 && c.lapses == 0)
      .length;
  final rememberingVocab = allVocab
      .where((c) => c.reps > 0 && c.lapses == 0)
      .length;
  final remembering = rememberingKanji + rememberingVocab + learnedGrammar;

  final notLearnedKanji = allKanji.where((c) => c.reps == 0).length;
  final notLearnedVocab = allVocab.where((c) => c.reps == 0).length;
  final notLearnedGrammar = allGrammar.where((c) => !c.isLearned).length;
  final notLearned = notLearnedKanji + notLearnedVocab + notLearnedGrammar;

  // Heatmap Data for last 105 days (15 weeks)
  final studyLogs = await db.select(db.studyLogTable).get();
  final Map<DateTime, int> heatmap = {};
  final now = DateTime.now();
  final todayNormalized = DateTime(now.year, now.month, now.day);

  // Initialize last 105 days with 0
  for (int i = 0; i < 105; i++) {
    final date = todayNormalized.subtract(Duration(days: i));
    heatmap[date] = 0;
  }

  // Aggregate study counts
  for (final log in studyLogs) {
    final logDate = DateTime(log.date.year, log.date.month, log.date.day);
    if (heatmap.containsKey(logDate)) {
      heatmap[logDate] = (heatmap[logDate] ?? 0) + log.count;
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

  // Review behavior insights (last 30 days)
  final reviewLogs = await db.select(db.reviewLogTable).get();
  final thirtyDaysAgo = todayNormalized.subtract(const Duration(days: 29));
  final recentReviews = reviewLogs.where((log) {
    final reviewDay = DateTime(
      log.reviewTime.year,
      log.reviewTime.month,
      log.reviewTime.day,
    );
    return !reviewDay.isBefore(thirtyDaysAgo);
  }).toList();

  final reviewsLast30Days = recentReviews.length;
  final successfulReviews = recentReviews
      .where((log) => log.rating >= 3)
      .length;
  final successRateLast30Days = reviewsLast30Days == 0
      ? 0.0
      : successfulReviews / reviewsLast30Days;

  final activeDaysLast30Days = studyLogs.where((log) {
    final day = DateTime(log.date.year, log.date.month, log.date.day);
    return !day.isBefore(thirtyDaysAgo) && log.count > 0;
  }).length;

  final byType = <String, List<int>>{};
  for (final review in recentReviews) {
    byType.putIfAbsent(review.itemType, () => <int>[]).add(review.rating);
  }

  String weakestArea = 'Chưa đủ dữ liệu';
  String? weakestAreaType;
  double weakestAreaSuccessRate = 0.0;
  if (byType.isNotEmpty) {
    final typeRates = byType.entries.map((entry) {
      final ratings = entry.value;
      final ok = ratings.where((rating) => rating >= 3).length;
      final rate = ratings.isEmpty ? 0.0 : ok / ratings.length;
      return MapEntry(entry.key, rate);
    }).toList()..sort((a, b) => a.value.compareTo(b.value));

    final weakest = typeRates.first;
    weakestArea = _displayTypeName(weakest.key);
    weakestAreaType = weakest.key;
    weakestAreaSuccessRate = weakest.value;
  }

  final retention = _calculateRetention(studyLogs);
  final pathStats = await _calculateLearningPathStats(db);

  return AnalyticsData(
    learned: learned,
    remembering: remembering,
    notLearned: notLearned,
    heatmapData: heatmap,
    jlptProgress: jlpt,
    reviewsLast30Days: reviewsLast30Days,
    activeDaysLast30Days: activeDaysLast30Days,
    successRateLast30Days: successRateLast30Days,
    weakestArea: weakestArea,
    weakestAreaType: weakestAreaType,
    weakestAreaSuccessRate: weakestAreaSuccessRate,
    d1Retention: retention.$1,
    d7Retention: retention.$2,
    lessonCompletionRate: pathStats.lessonCompletionRate,
    dropoutPoint: pathStats.dropoutPoint,
    cohortByLevel: pathStats.cohortByLevel,
  );
});

String _displayTypeName(String itemType) {
  switch (itemType) {
    case 'kanji':
      return 'Chữ Hán';
    case 'vocab':
    case 'vocabulary':
      return 'Từ vựng';
    case 'grammar':
      return 'Ngữ pháp';
    default:
      return itemType;
  }
}

(double, double) _calculateRetention(List<dynamic> studyLogs) {
  final days = studyLogs
      .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
      .toSet();
  if (days.isEmpty) return (0.0, 0.0);

  int d1Base = 0;
  int d1Retained = 0;
  int d7Base = 0;
  int d7Retained = 0;
  final today = DateTime.now();
  final normalizedToday = DateTime(today.year, today.month, today.day);

  for (final day in days) {
    if (day.isBefore(normalizedToday.subtract(const Duration(days: 1)))) {
      d1Base++;
      if (days.contains(day.add(const Duration(days: 1)))) d1Retained++;
    }
    if (day.isBefore(normalizedToday.subtract(const Duration(days: 7)))) {
      d7Base++;
      if (days.contains(day.add(const Duration(days: 7)))) d7Retained++;
    }
  }

  final d1 = d1Base == 0 ? 0.0 : d1Retained / d1Base;
  final d7 = d7Base == 0 ? 0.0 : d7Retained / d7Base;
  return (d1, d7);
}

Future<_LearningPathStats> _calculateLearningPathStats(dynamic db) async {
  final lessonRows = await db.select(db.lessonTable).get();
  final completedIds = lessonRows.map((row) => row.id).toSet();

  final json = await rootBundle.loadString('assets/data/unified_path.json');
  final decoded = (jsonDecode(json) as List).cast<Map<String, dynamic>>();

  final Map<String, int> totalByLevel = {for (var i = 1; i <= 5; i++) 'N$i': 0};
  final Map<String, int> completedByLevel = {
    for (var i = 1; i <= 5; i++) 'N$i': 0,
  };
  int totalLessons = 0;
  int completedLessons = 0;

  for (final item in decoded) {
    final id = item['id']?.toString() ?? '';
    final level = int.tryParse(item['level']?.toString() ?? '') ?? 5;
    final levelKey = 'N$level';

    final categories = <String, bool>{
      'mixed': true,
      'vocabulary': (item['vocabIds'] as List?)?.isNotEmpty ?? false,
      'grammar': (item['grammarIds'] as List?)?.isNotEmpty ?? false,
      'kanji': (item['kanjiIds'] as List?)?.isNotEmpty ?? false,
    };

    for (final entry in categories.entries) {
      if (!entry.value) continue;
      final lessonId = '${id}_${entry.key}';
      totalLessons++;
      totalByLevel[levelKey] = (totalByLevel[levelKey] ?? 0) + 1;
      if (completedIds.contains(lessonId)) {
        completedLessons++;
        completedByLevel[levelKey] = (completedByLevel[levelKey] ?? 0) + 1;
      }
    }
  }

  final cohortByLevel = <String, double>{};
  for (final key in totalByLevel.keys) {
    final total = totalByLevel[key] ?? 0;
    final done = completedByLevel[key] ?? 0;
    cohortByLevel[key] = total == 0 ? 0.0 : done / total;
  }

  final startedLevels = cohortByLevel.entries
      .where((e) => e.value > 0)
      .toList();
  String dropoutPoint = 'Chưa đủ dữ liệu';
  if (startedLevels.isNotEmpty) {
    startedLevels.sort((a, b) => a.value.compareTo(b.value));
    dropoutPoint = startedLevels.first.key;
  }

  return _LearningPathStats(
    lessonCompletionRate: totalLessons == 0
        ? 0.0
        : completedLessons / totalLessons,
    dropoutPoint: dropoutPoint,
    cohortByLevel: cohortByLevel,
  );
}

class _LearningPathStats {
  final double lessonCompletionRate;
  final String dropoutPoint;
  final Map<String, double> cohortByLevel;

  const _LearningPathStats({
    required this.lessonCompletionRate,
    required this.dropoutPoint,
    required this.cohortByLevel,
  });
}
