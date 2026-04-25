import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/lesson.dart';
import 'kanji_library_provider.dart';
import '../../data/datasources/app_database.dart';

final learningPathProvider = StateNotifierProvider<LearningPathNotifier, List<Lesson>>((ref) {
  final db = ref.watch(databaseProvider);
  // Watch initializer so it reloads when seeding is done
  ref.watch(databaseInitializerProvider);
  return LearningPathNotifier(db);
});

final selectedLevelProvider = StateProvider<int>((ref) => 5);

class LearningPathNotifier extends StateNotifier<List<Lesson>> {
  final AppDatabase _db;

  LearningPathNotifier(this._db) : super([]) {
    loadLessons();
  }

  Future<void> loadLessons() async {
    // Fetch all kanji cards to group them into lessons
    final allCards = await (_db.select(_db.kanjiCardTable)
          ..orderBy([(t) => OrderingTerm(expression: t.jlptLevel, mode: OrderingMode.desc)]))
        .get();

    // Fetch completed lesson IDs from DB
    final completedLessonRows = await _db.select(_db.lessonTable).get();
    final completedIds = completedLessonRows.map((r) => r.id).toSet();

    final lessons = <Lesson>[];
    
    // Group by JLPT level
    for (int level = 5; level >= 1; level--) {
      final levelCards = allCards.where((c) => c.jlptLevel == level).toList();
      if (levelCards.isEmpty) continue;

      // Split into lessons of 10 kanji each
      const cardsPerLesson = 10;
      for (int i = 0; i < levelCards.length; i += cardsPerLesson) {
        final end = (i + cardsPerLesson < levelCards.length) 
            ? i + cardsPerLesson 
            : levelCards.length;
        final lessonCards = levelCards.sublist(i, end);
        final id = 'n${level}_unit_${(i ~/ cardsPerLesson) + 1}';
        
        // A lesson is unlocked if it's the first one or the previous one is completed
        bool isUnlocked = lessons.isEmpty || (lessons.last.isCompleted);
        
        lessons.add(Lesson(
          id: id,
          title: 'N$level - Bài ${(i ~/ cardsPerLesson) + 1}',
          kanjiIds: lessonCards.map((c) => c.id).toList(),
          isCompleted: completedIds.contains(id),
          isUnlocked: isUnlocked,
        ));
      }
    }

    state = lessons;
  }

  Future<void> toggleLessonCompletion(String id) async {
    final lesson = state.firstWhere((l) => l.id == id);
    final isCompleted = !lesson.isCompleted;

    if (isCompleted) {
      await _db.into(_db.lessonTable).insertOnConflictUpdate(
        LessonTableCompanion.insert(id: id, isCompleted: const Value(true))
      );
    } else {
      await (_db.delete(_db.lessonTable)..where((t) => t.id.equals(id))).go();
    }

    await loadLessons();
  }
}