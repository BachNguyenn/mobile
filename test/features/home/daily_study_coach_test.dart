import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/features/learning/domain/entities/lesson.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';

void main() {
  const coach = DailyStudyCoach();

  group('DailyStudyCoach', () {
    test('prioritizes due review items', () {
      final plan = coach.recommend(
        progress: _progress(),
        dueCounts: const {
          LearningCategory.kanji: 2,
          LearningCategory.vocabulary: 7,
          LearningCategory.grammar: 1,
        },
        lessons: const [],
        defaultCategory: LearningCategory.mixed,
        level: 4,
      );

      expect(plan.actionType, DailyStudyActionType.review);
      expect(plan.category, LearningCategory.vocabulary);
      expect(plan.itemCount, 7);
      expect(plan.reason, contains('7'));
    });

    test('uses weakest due area when it has work available', () {
      final plan = coach.recommend(
        progress: _progress(),
        dueCounts: const {
          LearningCategory.kanji: 8,
          LearningCategory.vocabulary: 1,
          LearningCategory.grammar: 3,
        },
        lessons: const [],
        defaultCategory: LearningCategory.mixed,
        level: 3,
        weakestCategory: LearningCategory.grammar,
      );

      expect(plan.actionType, DailyStudyActionType.review);
      expect(plan.category, LearningCategory.grammar);
      expect(plan.itemCount, 3);
    });

    test('falls back to the first open lesson when nothing is due', () {
      final plan = coach.recommend(
        progress: _progress(),
        dueCounts: const {
          LearningCategory.kanji: 0,
          LearningCategory.vocabulary: 0,
          LearningCategory.grammar: 0,
        },
        lessons: const [
          Lesson(
            id: 'done',
            title: 'Done',
            isCompleted: true,
            isUnlocked: true,
          ),
          Lesson(
            id: 'next',
            title: 'Next grammar',
            grammarIds: ['g1', 'g2'],
            isUnlocked: true,
          ),
        ],
        defaultCategory: LearningCategory.mixed,
        level: 5,
        weakestCategory: LearningCategory.grammar,
      );

      expect(plan.actionType, DailyStudyActionType.lesson);
      expect(plan.category, LearningCategory.grammar);
      expect(plan.subtitle, 'Next grammar');
      expect(plan.reason, contains('Ngữ pháp'));
    });

    test('recommends placement when no learning data exists', () {
      final plan = coach.recommend(
        progress: HomeProgress.empty,
        dueCounts: const {
          LearningCategory.kanji: 0,
          LearningCategory.vocabulary: 0,
          LearningCategory.grammar: 0,
        },
        lessons: const [],
        defaultCategory: LearningCategory.mixed,
        level: 5,
      );

      expect(plan.actionType, DailyStudyActionType.placement);
      expect(plan.reason, 'Chưa có dữ liệu học');
    });
  });
}

HomeProgress _progress() {
  return const HomeProgress(
    kanji: ModuleProgress(
      title: 'Kanji',
      learned: 1,
      total: 10,
      percentage: .1,
    ),
    vocabulary: ModuleProgress(
      title: 'Vocabulary',
      learned: 2,
      total: 10,
      percentage: .2,
    ),
    grammar: ModuleProgress(
      title: 'Grammar',
      learned: 3,
      total: 10,
      percentage: .3,
    ),
    streak: 1,
    overdueCount: 0,
    todayReviewed: 0,
  );
}
