import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_repository_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_repository_provider.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/providers/study_event_provider.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_repository_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';

typedef OpenLearningCategoryCallback = void Function(LearningCategory category);

final dailyStudyCoachProvider = Provider<DailyStudyCoach>((ref) {
  return const DailyStudyCoach();
});

final dailyStudyPlanProvider = FutureProvider<DailyStudyPlan>((ref) async {
  await ref.watch(databaseInitializerProvider.future);
  ref.watch(studyEventStreamProvider);

  final settings =
      ref.watch(settingsProvider).valueOrNull ?? AppSettings.defaults;
  final level = settings.currentJlptLevel;
  final now = DateTime.now();

  final progress = await ref.watch(homeProgressProvider.future);
  final analytics = await ref.watch(analyticsProvider.future);
  final weakestCategory = _categoryFromAnalyticsType(analytics.weakestAreaType);

  final kanjiRepository = ref.read(kanjiRepositoryProvider);
  final vocabularyRepository = ref.read(vocabularyRepositoryProvider);
  final grammarRepository = ref.read(grammarRepositoryProvider);

  final dueCounts = <LearningCategory, int>{
    LearningCategory.kanji: await kanjiRepository.countDueCards(
      now,
      jlptLevel: level,
    ),
    LearningCategory.vocabulary: await vocabularyRepository.countDueVocabulary(
      now,
      jlptLevel: level,
    ),
    LearningCategory.grammar: await grammarRepository.countDueGrammar(
      jlptLevel: level,
    ),
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

Future<void> openDailyStudyPlan(
  BuildContext context,
  WidgetRef ref,
  DailyStudyPlan plan, {
  OpenLearningCategoryCallback? onOpenLearningCategory,
}) async {
  await ref.read(settingsProvider.notifier).updateCurrentJlptLevel(plan.level);
  ref.read(selectedLevelProvider.notifier).state = plan.level;

  switch (plan.actionType) {
    case DailyStudyActionType.review:
      final items = await loadReviewItemsForPlan(ref, plan);
      if (!context.mounted) return;
      if (items.isEmpty) {
        _openLearning(context, ref, plan.category, onOpenLearningCategory);
        return;
      }
      Navigator.push(context, AppRoutes.review(items));
      return;
    case DailyStudyActionType.lesson:
      if (!context.mounted) return;
      _openLearning(context, ref, plan.category, onOpenLearningCategory);
      return;
    case DailyStudyActionType.placement:
      if (!context.mounted) return;
      Navigator.push(context, AppRoutes.placementTest());
      return;
    case DailyStudyActionType.sentencePractice:
      if (!context.mounted) return;
      Navigator.push(context, AppRoutes.sentencePractice());
      return;
  }
}

Future<List<ReviewItem>> loadReviewItemsForPlan(
  WidgetRef ref,
  DailyStudyPlan plan,
) async {
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
          .getGrammarPointsByLevel(plan.level);
      return grammar
          .where((item) => !item.isLearned)
          .take(20)
          .map(ReviewItem.fromGrammar)
          .toList(growable: false);
    case LearningCategory.mixed:
      final kanji = await ref
          .read(kanjiRepositoryProvider)
          .getDueCards(now, jlptLevel: plan.level, limit: 8);
      final vocabulary = await ref
          .read(vocabularyRepositoryProvider)
          .getDueVocabulary(now, jlptLevel: plan.level, limit: 8);
      final grammar = await ref
          .read(grammarRepositoryProvider)
          .getGrammarPointsByLevel(plan.level);
      return [
        ...kanji.map(ReviewItem.fromKanji),
        ...vocabulary.map((item) => ReviewItem.fromVocabulary(item)),
        ...grammar
            .where((item) => !item.isLearned)
            .take(4)
            .map(ReviewItem.fromGrammar),
      ];
  }
}

void _openLearning(
  BuildContext context,
  WidgetRef ref,
  LearningCategory category,
  OpenLearningCategoryCallback? onOpenLearningCategory,
) {
  ref.read(learningCategoryProvider.notifier).state = category;
  final callback = onOpenLearningCategory;
  if (callback != null) {
    callback(category);
  } else {
    Navigator.push(context, AppRoutes.learningPath(initialCategory: category));
  }
}

LearningCategory? _categoryFromAnalyticsType(String? type) {
  return switch (type) {
    'kanji' => LearningCategory.kanji,
    'vocab' || 'vocabulary' => LearningCategory.vocabulary,
    'grammar' => LearningCategory.grammar,
    _ => null,
  };
}
