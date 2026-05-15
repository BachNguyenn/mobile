import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
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

  final countResults = await Future.wait<int>([
    _count(db, 'SELECT COUNT(*) AS value FROM kanji_card_table WHERE reps > 0'),
    _count(db, 'SELECT COUNT(*) AS value FROM vocabulary_table WHERE reps > 0'),
    _count(
      db,
      'SELECT COUNT(*) AS value FROM grammar_table WHERE is_learned = 1',
    ),
    _count(
      db,
      'SELECT COUNT(*) AS value FROM kanji_card_table WHERE reps > 0 AND lapses = 0',
    ),
    _count(
      db,
      'SELECT COUNT(*) AS value FROM vocabulary_table WHERE reps > 0 AND lapses = 0',
    ),
    _count(db, 'SELECT COUNT(*) AS value FROM kanji_card_table WHERE reps = 0'),
    _count(db, 'SELECT COUNT(*) AS value FROM vocabulary_table WHERE reps = 0'),
    _count(
      db,
      'SELECT COUNT(*) AS value FROM grammar_table WHERE is_learned = 0',
    ),
  ]);

  final learnedKanji = countResults[0];
  final learnedVocab = countResults[1];
  final learnedGrammar = countResults[2];
  final learned = learnedKanji + learnedVocab + learnedGrammar;

  final rememberingKanji = countResults[3];
  final rememberingVocab = countResults[4];
  final remembering = rememberingKanji + rememberingVocab + learnedGrammar;

  final notLearnedKanji = countResults[5];
  final notLearnedVocab = countResults[6];
  final notLearnedGrammar = countResults[7];
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
  final jlpt = await _loadJlptProgress(db);

  // Review behavior insights (last 30 days)
  final thirtyDaysAgo = todayNormalized.subtract(const Duration(days: 29));
  final recentReviews = await (db.select(
    db.reviewLogTable,
  )..where((log) => log.reviewTime.isBiggerOrEqualValue(thirtyDaysAgo))).get();

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

Future<int> _count(
  dynamic db,
  String sql, [
  List<Variable> variables = const [],
]) {
  return db
      .customSelect(sql, variables: variables)
      .getSingle()
      .then((row) => row.read<int>('value'));
}

Future<Map<String, double>> _loadJlptProgress(dynamic db) async {
  final rows = await db.customSelect('''
        SELECT
          jlpt_level,
          COUNT(*) AS total,
          SUM(CASE WHEN reps > 0 THEN 1 ELSE 0 END) AS learned
        FROM kanji_card_table
        GROUP BY jlpt_level
      ''').get();

  final progress = {for (var level = 1; level <= 5; level++) 'N$level': 0.0};
  for (final row in rows) {
    final level = row.read<int>('jlpt_level');
    final total = row.read<int>('total');
    final learned = row.read<int>('learned');
    progress['N$level'] = total == 0 ? 0.0 : learned / total;
  }
  return progress;
}

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
  final decoded = await compute(_decodeLearningPathItems, json);

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

List<Map<String, dynamic>> _decodeLearningPathItems(String source) {
  return (jsonDecode(source) as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList(growable: false);
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
