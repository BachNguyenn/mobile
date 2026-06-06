class ProgressSyncSummary {
  final bool hasCloudBackup;
  final DateTime? cloudUpdatedAt;
  final int kanjiCount;
  final int vocabularyCount;
  final int grammarCount;
  final int completedLessonCount;
  final int studyLogCount;
  final bool settingsIncluded;

  const ProgressSyncSummary({
    required this.hasCloudBackup,
    this.cloudUpdatedAt,
    this.kanjiCount = 0,
    this.vocabularyCount = 0,
    this.grammarCount = 0,
    this.completedLessonCount = 0,
    this.studyLogCount = 0,
    this.settingsIncluded = false,
  });

  static const empty = ProgressSyncSummary(hasCloudBackup: false);

  int get totalSyncedItems =>
      kanjiCount +
      vocabularyCount +
      grammarCount +
      completedLessonCount +
      studyLogCount;
}

class ProgressSyncResult {
  final ProgressSyncSummary summary;
  final String message;

  const ProgressSyncResult({required this.summary, required this.message});
}
