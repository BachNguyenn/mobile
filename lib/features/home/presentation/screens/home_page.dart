import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/garden/application/providers/garden_mission_provider.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/navigation/daily_study_navigation.dart';
import 'package:mobile/features/home/presentation/widgets/bento_dashboard.dart';
import 'package:mobile/features/home/presentation/widgets/daily_study_card.dart';
import 'package:mobile/features/home/presentation/widgets/home_top_bar.dart';
import 'package:mobile/features/home/presentation/widgets/mission_card.dart';
import 'package:mobile/features/home/presentation/widgets/quick_actions_bar.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/weakness/application/providers/weakness_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(homeProgressProvider).value;
    final dailyPlan = ref.watch(dailyStudyPlanProvider);
    final missions = ref.watch(gardenMissionProvider);
    final weakItems = ref.watch(weakItemsProvider).value ?? const [];
    final user = ref.watch(authStateProvider).value;
    final data = progress ?? HomeProgress.empty;

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp20,
                  AppSpacing.sp12,
                  AppSpacing.sp20,
                  116,
                ),
                sliver: SliverList.list(
                  children: [
                    HomeTopBar(user: user),
                    const SizedBox(height: AppSpacing.sp20),
                    DailyStudyCard(
                      plan: dailyPlan,
                      progress: data,
                      onTap: (plan) => openDailyStudyPlan(
                        context,
                        ref,
                        plan,
                        onOpenLearningCategory: onOpenLearningCategory,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    BentoDashboard(
                      progress: data,
                      weakItems: weakItems,
                      onOpenWeakness: () =>
                          Navigator.push(context, AppRoutes.weakness()),
                      onOpenGarden: () =>
                          Navigator.push(context, AppRoutes.garden()),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    QuickActionsBar(
                      onOpenWeakness: () =>
                          Navigator.push(context, AppRoutes.weakness()),
                      onOpenPlacement: () =>
                          Navigator.push(context, AppRoutes.placementTest()),
                      onOpenSentencePractice: () =>
                          Navigator.push(context, AppRoutes.sentencePractice()),
                      onOpenGarden: () =>
                          Navigator.push(context, AppRoutes.garden()),
                      onOpenAnalytics: () =>
                          Navigator.push(context, AppRoutes.analytics()),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    MissionCard(
                      missions: missions,
                      onTap: () => Navigator.push(context, AppRoutes.garden()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
