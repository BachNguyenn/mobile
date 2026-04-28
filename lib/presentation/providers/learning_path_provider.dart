import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/lesson.dart';
import '../../core/providers/database_provider.dart';
import '../../data/datasources/app_database.dart';

enum LearningCategory { vocabulary, grammar, kanji, mixed }

final learningCategoryProvider = StateProvider<LearningCategory>((ref) => LearningCategory.mixed);

final learningPathProvider =
    StateNotifierProvider<LearningPathNotifier, List<Lesson>>((ref) {
  final db = ref.watch(databaseProvider);
  final category = ref.watch(learningCategoryProvider);
  final level = ref.watch(selectedLevelProvider);
  // Watch initializer so it reloads when seeding is done
  ref.watch(databaseInitializerProvider);
  return LearningPathNotifier(db, category, level);
});

final selectedLevelProvider = StateProvider<int>((ref) => 5);

// Global cache for JSON data to avoid reloading from disk multiple times
List<dynamic>? _cachedJsonData;

class LearningPathNotifier extends StateNotifier<List<Lesson>> {
  final AppDatabase _db;
  final LearningCategory _category;
  final int _level;

  LearningPathNotifier(this._db, this._category, this._level) : super([]) {
    loadLessons();
  }

  Future<void> loadLessons() async {
    try {
      if (_cachedJsonData == null) {
        debugPrint('Loading JSON from assets...');
        final ByteData bytes = await rootBundle.load('assets/data/unified_path.json');
        final String jsonString = utf8.decode(bytes.buffer.asUint8List(), allowMalformed: true);
        _cachedJsonData = json.decode(jsonString) as List<dynamic>;
      }
      
      final data = _cachedJsonData!;
      debugPrint('Processing ${data.length} items from JSON...');

      // Fetch completed lesson IDs from DB
      final completedLessonRows = await _db.select(_db.lessonTable).get();
      final completedIds = completedLessonRows.map((r) => r.id).toSet();

      final lessons = <Lesson>[];

      for (var jsonItem in data) {
        final levelValue = jsonItem['level'];
        final level = levelValue is int 
            ? levelValue 
            : int.tryParse(levelValue?.toString() ?? '') ?? 0;
            
        if (level != _level) continue;

        final id = jsonItem['id'] as String? ?? '';
        final typeStr = jsonItem['type'] as String? ?? 'lesson';
        final type = typeStr == 'quiz' ? LessonType.quiz : LessonType.lesson;
        
        List<String> kanjiIds = List<String>.from(jsonItem['kanjiIds'] ?? []);
        List<String> vocabIds = List<String>.from(jsonItem['vocabIds'] ?? []);
        List<String> grammarIds = List<String>.from(jsonItem['grammarIds'] ?? []);

        // Filter based on category
        if (_category == LearningCategory.vocabulary) {
          if (vocabIds.isEmpty) continue;
          kanjiIds = [];
          grammarIds = [];
        } else if (_category == LearningCategory.grammar) {
          if (grammarIds.isEmpty) continue;
          kanjiIds = [];
          vocabIds = [];
        } else if (_category == LearningCategory.kanji) {
          if (kanjiIds.isEmpty) continue;
          vocabIds = [];
          grammarIds = [];
        }

        final categorySuffix = _category.name;
        final lessonId = '${id}_$categorySuffix';

        lessons.add(Lesson(
          id: lessonId,
          title: jsonItem['title'] as String? ?? 'Bài học',
          kanjiIds: kanjiIds,
          vocabIds: vocabIds,
          grammarIds: grammarIds,
          level: level,
          type: type,
          isCompleted: completedIds.contains(lessonId),
          isUnlocked: false,
        ));
      }

      // Re-calculate unlocking logic based on the current order
      for (int i = 0; i < lessons.length; i++) {
        bool isUnlocked = i == 0 || lessons[i - 1].isCompleted;
        lessons[i] = lessons[i].copyWith(isUnlocked: isUnlocked);
      }

      state = lessons;
      debugPrint('Loaded ${lessons.length} lessons successfully for level $_level, category ${_category.name}');
    } catch (e, stack) {
      debugPrint('Error loading learning path: $e');
      debugPrint('Stack trace: $stack');
      state = [];
    }
  }

  Future<void> toggleLessonCompletion(String id) async {
    final lessonIndex = state.indexWhere((l) => l.id == id);
    if (lessonIndex == -1) return;

    final lesson = state[lessonIndex];
    final isCompleted = !lesson.isCompleted;

    if (isCompleted) {
      await _db.into(_db.lessonTable).insertOnConflictUpdate(
          LessonTableCompanion.insert(id: id, isCompleted: const Value(true)));
    } else {
      await (_db.delete(_db.lessonTable)..where((t) => t.id.equals(id))).go();
    }

    await loadLessons();
  }
}