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
