import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/home/domain/repositories/home_progress_repository.dart';

class DriftHomeProgressRepository implements HomeProgressRepository {
  final AppDatabase _db;

  const DriftHomeProgressRepository(this._db);

  @override
  Future<HomeProgress> loadProgress() async {
    final now = DateTime.now();
    final soon = now.add(const Duration(hours: 24));

    final row = await _db
        .customSelect(
          '''
      SELECT
        (SELECT COUNT(*) FROM kanji_card_table WHERE reps > 0) AS learned_kanji,
        (SELECT COUNT(*) FROM kanji_card_table) AS total_kanji,
        (SELECT COUNT(*) FROM vocabulary_table WHERE reps > 0) AS learned_vocab,
        (SELECT COUNT(*) FROM vocabulary_table) AS total_vocab,
        (SELECT COUNT(*) FROM grammar_table WHERE is_learned = 1) AS learned_grammar,
        (SELECT COUNT(*) FROM grammar_table) AS total_grammar,
        (SELECT COUNT(*) FROM kanji_card_table WHERE next_review <= ?) AS due_kanji,
        (SELECT COUNT(*) FROM vocabulary_table WHERE next_review <= ?) AS due_vocab,
        (SELECT COUNT(*) FROM kanji_card_table WHERE next_review > ? AND next_review <= ?) AS due_soon_kanji,
        (SELECT COUNT(*) FROM vocabulary_table WHERE next_review > ? AND next_review <= ?) AS due_soon_vocab,
        COALESCE((SELECT exp FROM zen_garden_table LIMIT 1), 0) AS garden_exp,
        COALESCE((SELECT water FROM zen_garden_table LIMIT 1), 0) AS garden_water,
        COALESCE((SELECT sunlight FROM zen_garden_table LIMIT 1), 0) AS garden_sunlight,
        COALESCE((SELECT plants_json FROM zen_garden_table LIMIT 1), '[]') AS garden_plants_json
      ''',
          variables: [
            Variable.withDateTime(now),
            Variable.withDateTime(now),
            Variable.withDateTime(now),
            Variable.withDateTime(soon),
            Variable.withDateTime(now),
            Variable.withDateTime(soon),
          ],
        )
        .getSingle();

    final learnedKanji = row.read<int>('learned_kanji');
    final totalKanji = row.read<int>('total_kanji');
    final learnedVocab = row.read<int>('learned_vocab');
    final totalVocab = row.read<int>('total_vocab');
    final learnedGrammar = row.read<int>('learned_grammar');
    final totalGrammar = row.read<int>('total_grammar');
    final overdueCount =
        row.read<int>('due_kanji') + row.read<int>('due_vocab');
    final dueSoonCount =
        row.read<int>('due_soon_kanji') + row.read<int>('due_soon_vocab');
    final gardenPlantsJson = row.read<String>('garden_plants_json');

    final studyLogs =
        await (_db.select(_db.studyLogTable)..orderBy([
              (table) =>
                  OrderingTerm(expression: table.date, mode: OrderingMode.desc),
            ]))
            .get();

    final streak = _calculateStreak(studyLogs, now);
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayReviewed = studyLogs
        .where(
          (log) =>
              log.date.isAfter(todayStart) ||
              log.date.isAtSameMomentAs(todayStart),
        )
        .fold<int>(0, (sum, log) => sum + log.count);

    return HomeProgress(
      kanji: ModuleProgress(
        title: 'Chữ Hán',
        learned: learnedKanji,
        total: totalKanji,
        percentage: totalKanji > 0 ? learnedKanji / totalKanji : 0.0,
      ),
      vocabulary: ModuleProgress(
        title: 'Từ vựng',
        learned: learnedVocab,
        total: totalVocab,
        percentage: totalVocab > 0 ? learnedVocab / totalVocab : 0.0,
      ),
      grammar: ModuleProgress(
        title: 'Ngữ pháp',
        learned: learnedGrammar,
        total: totalGrammar,
        percentage: totalGrammar > 0 ? learnedGrammar / totalGrammar : 0.0,
      ),
      streak: streak,
      overdueCount: overdueCount,
      dueSoonCount: dueSoonCount,
      todayReviewed: todayReviewed,
      gardenExp: row.read<int>('garden_exp'),
      gardenWater: row.read<int>('garden_water'),
      gardenSunlight: row.read<int>('garden_sunlight'),
      gardenPlantCount: _countGardenPlants(gardenPlantsJson),
    );
  }

  int _countGardenPlants(String plantsJson) {
    try {
      final decoded = json.decode(plantsJson);
      return decoded is List ? decoded.length : 0;
    } on FormatException {
      return 0;
    }
  }

  int _calculateStreak(List<StudyLogTableData> logs, DateTime now) {
    if (logs.isEmpty) return 0;

    final studyDays =
        logs
            .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (studyDays.first != today && studyDays.first != yesterday) return 0;

    var streak = 0;
    var checkDate = studyDays.first;

    for (final day in studyDays) {
      if (day == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (day.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }
}
