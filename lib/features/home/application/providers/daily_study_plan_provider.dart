import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/bootstrap/database_initializer_provider.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/grammar/application/providers/grammar_repository_provider.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/application/providers/study_event_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_repository_provider.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

final dailyStudyCoachProvider = Provider<DailyStudyCoach>((ref) {
  return const DailyStudyCoach();
});

final weakestStudyAreaProvider = FutureProvider<LearningCategory?>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  ref.watch(studyEventStreamProvider);

  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thirtyDaysAgo = today.subtract(const Duration(days: 29));

  // SQLite-level aggregation to find the weakest area
  final row = await db.customSelect(
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
  ).getSingleOrNull();

  if (row == null) return null;
  return _categoryFromAnalyticsType(row.read<String>('item_type'));
});

final dailyStudyPlanProvider = FutureProvider<DailyStudyPlan>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  ref.watch(studyEventStreamProvider);

  final settings =
      ref.watch(settingsProvider).valueOrNull ?? AppSettings.defaults;
  final level = settings.currentJlptLevel;
  final now = DateTime.now();

  final progress = await ref.watch(homeProgressProvider.future);
  final weakestCategory = await ref.watch(weakestStudyAreaProvider.future);

  final kanjiRepository = ref.read(kanjiRepositoryProvider);
  final vocabularyRepository = ref.read(vocabularyRepositoryProvider);
  final grammarRepository = ref.read(grammarRepositoryProvider);

  // Parallelize due count queries
  final dueCountsResults = await Future.wait([
    kanjiRepository.countDueCards(now, jlptLevel: level),
    vocabularyRepository.countDueVocabulary(now, jlptLevel: level),
    grammarRepository.countDueGrammar(jlptLevel: level),
  ]);

  final dueCounts = <LearningCategory, int>{
    LearningCategory.kanji: dueCountsResults[0],
    LearningCategory.vocabulary: dueCountsResults[1],
    LearningCategory.grammar: dueCountsResults[2],
  };

  final hasDueItems = dueCounts.values.any((count) => count > 0);
  var lessonCategory = hasDueItems
      ? settings.defaultLearningCategory
      : weakestCategory ?? settings.defaultLearningCategory;
  var lessons = hasDueItems
      ? <Lesson>[]
      : await ref
            .read(learningPathRepositoryProvider)
            .getLessons(
              category: lessonCategory,
              level: level,
              goal: settings.learningGoal,
            );

  final hasOpenLesson = lessons.any((lesson) => !lesson.isCompleted);
  if (!hasDueItems &&
      !hasOpenLesson &&
      lessonCategory != LearningCategory.mixed) {
    lessonCategory = LearningCategory.mixed;
    lessons = await ref
        .read(learningPathRepositoryProvider)
        .getLessons(
          category: lessonCategory,
          level: level,
          goal: settings.learningGoal,
        );
  }

  return ref
      .read(dailyStudyCoachProvider)
      .recommend(
        progress: progress,
        dueCounts: dueCounts,
        lessons: lessons,
        defaultCategory: lessonCategory,
        level: level,
        weakestCategory: weakestCategory,
      );
});

final dailyStudyPlanReviewItemsProvider =
    FutureProvider.family<List<ReviewItem>, DailyStudyPlan>((ref, plan) async {
      final now = DateTime.now();
      switch (plan.category) {
        case LearningCategory.kanji:
          final cards = await ref
              .read(kanjiRepositoryProvider)
              .getDueCards(now, jlptLevel: plan.level, limit: 20);
          return cards.map(ReviewItem.fromKanji).toList(growable: false);
        case LearningCategory.vocabulary:
          final vocabulary = await ref
              .read(vocabularyRepositoryProvider)
              .getDueVocabulary(now, jlptLevel: plan.level, limit: 20);
          return vocabulary
              .map((item) => ReviewItem.fromVocabulary(item))
              .toList(growable: false);
        case LearningCategory.grammar:
          final grammar = await ref
              .read(grammarRepositoryProvider)
              .getDueGrammar(jlptLevel: plan.level, limit: 20);
          return grammar.map(ReviewItem.fromGrammar).toList(growable: false);
        case LearningCategory.mixed:
          // Parallelize mixed review sub-queries
          final results = await Future.wait([
            ref.read(kanjiRepositoryProvider).getDueCards(now, jlptLevel: plan.level, limit: 8),
            ref.read(vocabularyRepositoryProvider).getDueVocabulary(now, jlptLevel: plan.level, limit: 8),
            ref.read(grammarRepositoryProvider).getDueGrammar(jlptLevel: plan.level, limit: 4),
          ]);
          final kanji = results[0] as List<KanjiCard>;
          final vocabulary = results[1] as List<Vocabulary>;
          final grammar = results[2] as List<GrammarPoint>;
          return [
            ...kanji.map(ReviewItem.fromKanji),
            ...vocabulary.map((item) => ReviewItem.fromVocabulary(item)),
            ...grammar.map(ReviewItem.fromGrammar),
          ];
      }
    });

LearningCategory? _categoryFromAnalyticsType(String? type) {
  return switch (type) {
    'kanji' => LearningCategory.kanji,
    'vocab' || 'vocabulary' => LearningCategory.vocabulary,
    'grammar' => LearningCategory.grammar,
    _ => null,
  };
}
