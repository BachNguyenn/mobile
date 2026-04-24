import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/app_database.dart';
import 'kanji_library_provider.dart';
import 'study_event_provider.dart';

/// Progress data cho 1 module học tập (Kanji, Từ vựng, Ngữ pháp)
class ModuleProgress {
  final String title;
  final int learned;
  final int total;
  final double percentage;

  const ModuleProgress({
    required this.title,
    required this.learned,
    required this.total,
    required this.percentage,
  });

  static const empty = ModuleProgress(
    title: '',
    learned: 0,
    total: 0,
    percentage: 0.0,
  );
}

/// Progress tổng hợp cho cả 3 module trên Home
class HomeProgress {
  final ModuleProgress kanji;
  final ModuleProgress vocabulary;
  final ModuleProgress grammar;
  final int streak;
  final int overdueCount;
  final int todayReviewed;

  const HomeProgress({
    required this.kanji,
    required this.vocabulary,
    required this.grammar,
    required this.streak,
    required this.overdueCount,
    required this.todayReviewed,
  });

  static const empty = HomeProgress(
    kanji: ModuleProgress.empty,
    vocabulary: ModuleProgress.empty,
    grammar: ModuleProgress.empty,
    streak: 0,
    overdueCount: 0,
    todayReviewed: 0,
  );

  /// Tổng % hoàn thành trung bình
  double get overallPercentage {
    if (kanji.total == 0) return 0.0;
    return kanji.percentage; // Hiện tại chỉ có Kanji data
  }
}

/// Provider chính — tính toán progress cho Home screen
///
/// Tự động rebuild khi có study event mới (reactive cross-tab).
final homeProgressProvider = FutureProvider<HomeProgress>((ref) async {
  // Lắng nghe study events để auto-refresh
  ref.watch(studyEventStreamProvider);

  final db = ref.watch(databaseProvider);

  // ── Kanji Progress ──────────────────────────────────────
  final allCards = await db.select(db.kanjiCardTable).get();
  final learnedKanji = allCards.where((c) => c.reps > 0).length;
  final totalKanji = allCards.length;
  final kanjiPercentage = totalKanji > 0 ? learnedKanji / totalKanji : 0.0;

  // ── Overdue Count ───────────────────────────────────────
  final now = DateTime.now();
  final overdueCards = allCards.where(
    (c) => c.reps > 0 && c.nextReview.isBefore(now),
  );
  final overdueCount = overdueCards.length;

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
    // Placeholder cho Từ vựng — sẽ implement khi có data
    vocabulary: const ModuleProgress(
      title: 'Từ vựng',
      learned: 0,
      total: 0,
      percentage: 0.0,
    ),
    // Placeholder cho Ngữ pháp — sẽ implement khi có data
    grammar: const ModuleProgress(
      title: 'Ngữ pháp',
      learned: 0,
      total: 0,
      percentage: 0.0,
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
