import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';

typedef OpenLearningCategoryCallback = void Function(LearningCategory category);

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
      final items = await ref.read(
        dailyStudyPlanReviewItemsProvider(plan).future,
      );
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
