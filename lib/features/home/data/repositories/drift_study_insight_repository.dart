import 'package:drift/drift.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/home/domain/repositories/study_insight_repository.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';

class DriftStudyInsightRepository implements StudyInsightRepository {
  final AppDatabase _db;

  const DriftStudyInsightRepository(this._db);

  @override
  Future<LearningCategory?> findWeakestStudyArea() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thirtyDaysAgo = today.subtract(const Duration(days: 29));

    final row = await _db
        .customSelect(
          '''
      SELECT item_type,
        AVG(CASE WHEN rating >= 3 THEN 1.0 ELSE 0.0 END) as success_rate
      FROM review_log_table
      WHERE review_time >= ?
      GROUP BY item_type
      ORDER BY success_rate ASC
      LIMIT 1
      ''',
          variables: [Variable.withDateTime(thirtyDaysAgo)],
        )
        .getSingleOrNull();

    if (row == null) return null;
    return _categoryFromAnalyticsType(row.read<String>('item_type'));
  }

  LearningCategory? _categoryFromAnalyticsType(String? type) {
    return switch (type) {
      'kanji' => LearningCategory.kanji,
      'vocab' || 'vocabulary' => LearningCategory.vocabulary,
      'grammar' => LearningCategory.grammar,
      _ => null,
    };
  }
}
