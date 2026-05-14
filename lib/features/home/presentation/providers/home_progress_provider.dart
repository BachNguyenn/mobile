import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_repository_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_repository_provider.dart';
import 'package:mobile/features/review/presentation/providers/study_event_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_repository_provider.dart';

final homeProgressProvider = FutureProvider<HomeProgress>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  ref.watch(studyEventStreamProvider);

  final db = ref.watch(databaseProvider);
  final kanjiRepo = ref.watch(kanjiRepositoryProvider);
  final vocabRepo = ref.watch(vocabularyRepositoryProvider);
  final grammarRepo = ref.watch(grammarRepositoryProvider);
  final now = DateTime.now();

  final counts = await Future.wait<int>([
    kanjiRepo.countLearnedCards(),
    kanjiRepo.countCards(),
    vocabRepo.countLearnedVocabulary(),
    vocabRepo.countVocabulary(),
    grammarRepo.countLearnedGrammar(),
    grammarRepo.countGrammarPoints(),
    kanjiRepo.countDueCards(now),
    vocabRepo.countDueVocabulary(now),
  ]);

  final learnedKanji = counts[0];
  final totalKanji = counts[1];
  final learnedVocab = counts[2];
  final totalVocab = counts[3];
  final learnedGrammar = counts[4];
  final totalGrammar = counts[5];
  final overdueCount = counts[6] + counts[7];

  final studyLogs = await db.select(db.studyLogTable).get();
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
    todayReviewed: todayReviewed,
  );
});

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
