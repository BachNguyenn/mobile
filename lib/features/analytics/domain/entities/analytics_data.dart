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

  const AnalyticsData({
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
