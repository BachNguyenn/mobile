import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_mission_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/screens/home_page.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';

void main() {
  testWidgets('renders daily study plan on home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          homeProgressProvider.overrideWith((ref) async => _progress),
          dailyStudyPlanProvider.overrideWith(
            (ref) async => const DailyStudyPlan(
              title: 'Ôn lại từ vựng',
              subtitle: 'Một phiên ngắn để giữ trí nhớ ổn định.',
              reason: '12 thẻ đến hạn',
              actionType: DailyStudyActionType.review,
              category: LearningCategory.vocabulary,
              level: 5,
              itemCount: 12,
            ),
          ),
          gardenMissionProvider.overrideWith(
            (ref) async => const GardenMissionSummary(
              missions: [],
              todayStudyCount: 0,
              maxCorrectStreak: 0,
            ),
          ),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hôm nay học gì?'), findsOneWidget);
    expect(find.text('Ôn lại từ vựng'), findsOneWidget);
    expect(find.text('12 thẻ đến hạn'), findsOneWidget);
    expect(find.text('Bắt đầu ngay'), findsOneWidget);
  });
}

const _progress = HomeProgress(
  kanji: ModuleProgress(title: 'Kanji', learned: 2, total: 10, percentage: .2),
  vocabulary: ModuleProgress(
    title: 'Vocabulary',
    learned: 4,
    total: 10,
    percentage: .4,
  ),
  grammar: ModuleProgress(
    title: 'Grammar',
    learned: 1,
    total: 10,
    percentage: .1,
  ),
  streak: 3,
  overdueCount: 12,
  todayReviewed: 5,
);
