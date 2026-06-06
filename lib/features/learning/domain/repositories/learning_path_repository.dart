import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/learning/domain/entities/lesson.dart';

abstract class LearningPathRepository {
  Future<List<Lesson>> getLessons({
    required LearningCategory category,
    required int level,
    LearningGoal goal,
  });

  Future<void> setLessonCompletion(String id, bool isCompleted);
}
