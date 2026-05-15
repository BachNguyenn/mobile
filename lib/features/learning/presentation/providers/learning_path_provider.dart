import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/providers/database_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/data/repositories/learning_path_repository.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';

export 'package:mobile/features/learning/domain/entities/learning_category.dart';

final learningPathRepositoryProvider = Provider<LearningPathRepository>((ref) {
  return LearningPathRepository(ref.watch(databaseProvider));
});

final learningCategoryProvider = StateProvider<LearningCategory>(
  (ref) => LearningCategory.mixed,
);

final selectedLevelProvider = StateProvider<int>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return settings?.currentJlptLevel ?? AppSettings.defaults.currentJlptLevel;
});

final learningPathProvider =
    StateNotifierProvider<LearningPathNotifier, List<Lesson>>((ref) {
      final repository = ref.watch(learningPathRepositoryProvider);
      final category = ref.watch(learningCategoryProvider);
      final level = ref.watch(selectedLevelProvider);
      final settings =
          ref.watch(settingsProvider).valueOrNull ?? AppSettings.defaults;
      ref.watch(databaseInitializerProvider);
      return LearningPathNotifier(
        repository,
        category,
        level,
        settings.learningGoal,
      );
    });

class LearningPathNotifier extends StateNotifier<List<Lesson>> {
  final LearningPathRepository _repository;
  final LearningCategory _category;
  final int _level;
  final LearningGoal _goal;

  LearningPathNotifier(
    this._repository,
    this._category,
    this._level,
    this._goal,
  ) : super([]) {
    loadLessons();
  }

  Future<void> loadLessons() async {
    try {
      final lessons = await _repository.getLessons(
        category: _category,
        level: _level,
        goal: _goal,
      );
      if (!mounted) return;
      state = lessons;
    } catch (_) {
      if (!mounted) return;
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
