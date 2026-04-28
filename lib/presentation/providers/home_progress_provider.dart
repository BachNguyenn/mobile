import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/database_provider.dart';
import '../../data/datasources/app_database.dart';
import 'study_event_provider.dart';
import '../../core/models/progress_models.dart';

/// Provider chính — tính toán progress cho Home screen
///
/// Tự động rebuild khi có study event mới (reactive cross-tab).
final homeProgressProvider = FutureProvider<HomeProgress>((ref) async {
  // Wait for db seeding first
  await ref.watch(databaseInitializerProvider.future);

  // Lắng nghe study events để auto-refresh
  ref.watch(studyEventStreamProvider);

  final db = ref.watch(databaseProvider);

  // ── Kanji Progress ──────────────────────────────────────
  final allCards = await db.select(db.kanjiCardTable).get();
  final learnedKanji = allCards.where((c) => c.reps > 0).length;
  final totalKanji = allCards.length;
  final kanjiPercentage = totalKanji > 0 ? learnedKanji / totalKanji : 0.0;

  // ── Vocabulary Progress ─────────────────────────────────
  final allVocab = await db.select(db.vocabularyTable).get();
  final learnedVocab = allVocab.where((c) => c.reps > 0).length;
  final totalVocab = allVocab.length;
  final vocabPercentage = totalVocab > 0 ? learnedVocab / totalVocab : 0.0;

  // ── Grammar Progress ────────────────────────────────────
  final allGrammar = await db.select(db.grammarTable).get();
  final learnedGrammar = allGrammar.where((c) => c.isLearned).length;
  final totalGrammar = allGrammar.length;
  final grammarPercentage = totalGrammar > 0 ? learnedGrammar / totalGrammar : 0.0;

  // ── Overdue Count (Combined) ────────────────────────────
  final now = DateTime.now();
  final overdueKanji = allCards.where((c) => c.reps > 0 && c.nextReview.isBefore(now)).length;
  final overdueVocab = allVocab.where((c) => c.reps > 0 && c.nextReview.isBefore(now)).length;
  final overdueCount = overdueKanji + overdueVocab;

  // ── Streak (số ngày liên tục có học) ────────────────────
  final studyLogs = await db.select(db.studyLogTable).get();
  int streak = _calculateStreak(studyLogs, now);

  // ── Today's reviewed count ──────────────────────────────
  final todayStart = DateTime(now.year, now.month, now.day);
  final todayLog = studyLogs.where(
    (log) => log.date.isAfter(todayStart) || log.date.isAtSameMomentAs(todayStart),
  );
  final todayReviewed = todayLog.fold<int>(0, (sum, log) => sum + log.count);

  return HomeProgress(
    kanji: ModuleProgress(
      title: 'Chữ Hán',
      learned: learnedKanji,
      total: totalKanji,
      percentage: kanjiPercentage,
    ),
    vocabulary: ModuleProgress(
      title: 'Từ vựng',
      learned: learnedVocab,
      total: totalVocab,
      percentage: vocabPercentage,
    ),
    grammar: ModuleProgress(
      title: 'Ngữ pháp',
      learned: learnedGrammar,
      total: totalGrammar,
      percentage: grammarPercentage,
    ),
    streak: streak,
    overdueCount: overdueCount,
    todayReviewed: todayReviewed,
  );
});

/// Tính streak: đếm ngược từ hôm nay, mỗi ngày liên tục có study log
int _calculateStreak(List<StudyLogTableData> logs, DateTime now) {
  if (logs.isEmpty) return 0;

  // Lấy set các ngày có study log (chỉ year/month/day)
  final studyDays = logs
      .map((log) => DateTime(log.date.year, log.date.month, log.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a)); // Mới nhất trước

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Streak bắt đầu từ hôm nay hoặc hôm qua
  if (studyDays.isEmpty) return 0;
  if (studyDays.first != today && studyDays.first != yesterday) return 0;

  int streak = 0;
  DateTime checkDate = studyDays.first;

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
