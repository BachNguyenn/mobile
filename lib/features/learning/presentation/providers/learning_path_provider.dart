import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/data/repositories/learning_path_repository.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';

export 'package:mobile/features/learning/domain/entities/learning_category.dart';

final learningPathRepositoryProvider = Provider<LearningPathRepository>((ref) {
  return LearningPathRepository(ref.watch(databaseProvider));
});

final learningCategoryProvider = StateProvider<LearningCategory>(
  (ref) => LearningCategory.mixed,
);

final selectedLevelProvider = StateProvider<int>((ref) => 5);

final learningPathProvider =
    StateNotifierProvider<LearningPathNotifier, List<Lesson>>((ref) {
  final repository = ref.watch(learningPathRepositoryProvider);
  final category = ref.watch(learningCategoryProvider);
  final level = ref.watch(selectedLevelProvider);
  ref.watch(databaseInitializerProvider);
  return LearningPathNotifier(repository, category, level);
});

class LearningPathNotifier extends StateNotifier<List<Lesson>> {
  final LearningPathRepository _repository;
  final LearningCategory _category;
  final int _level;

  LearningPathNotifier(this._repository, this._category, this._level)
      : super([]) {
    loadLessons();
  }

  Future<void> loadLessons() async {
    try {
      state = await _repository.getLessons(
        category: _category,
        level: _level,
      );
    } catch (_) {
      state = [];
    }
  }

  Future<void> toggleLessonCompletion(String id) async {
    final lessonIndex = state.indexWhere((lesson) => lesson.id == id);
    if (lessonIndex == -1) return;

    final lesson = state[lessonIndex];
    await _repository.setLessonCompletion(id, !lesson.isCompleted);
    await loadLessons();
  }
}
