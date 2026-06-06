import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile/data/datasources/app_database.dart';
import 'package:mobile/features/learning/domain/entities/lesson.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/learning/domain/repositories/learning_path_repository.dart';

class AssetLearningPathRepository implements LearningPathRepository {
  final AppDatabase _db;
  final Future<List<Map<String, dynamic>>> Function() _loadPathData;

  AssetLearningPathRepository(
    this._db, {
    required Future<List<Map<String, dynamic>>> Function() loadPathData,
  }) : _loadPathData = loadPathData;

  static Future<List<Map<String, dynamic>>> loadPathDataFromAssets() async {
    final bytes = await rootBundle.load('assets/data/unified_path.json');
    final jsonString = utf8.decode(
      bytes.buffer.asUint8List(),
      allowMalformed: true,
    );
    return compute(_decodePathData, jsonString);
  }

  @override
  Future<List<Lesson>> getLessons({
    required LearningCategory category,
    required int level,
    LearningGoal goal = LearningGoal.jlpt,
  }) async {
    final data = await _loadPathData();
    final completedLessonRows = await _db.select(_db.lessonTable).get();
    final completedIds = completedLessonRows.map((row) => row.id).toSet();

    final lessons = <Lesson>[];
    for (final item in data) {
      final parsedLevel = _parseLevel(item['level']);
      if (parsedLevel != level) continue;

      final id = item['id'] as String? ?? '';
      final typeStr = item['type'] as String? ?? 'lesson';
      final type = typeStr == 'quiz' ? LessonType.quiz : LessonType.lesson;

      var kanjiIds = List<String>.from(item['kanjiIds'] ?? []);
      var vocabIds = List<String>.from(item['vocabIds'] ?? []);
      var grammarIds = List<String>.from(item['grammarIds'] ?? []);

      if (category == LearningCategory.vocabulary) {
        if (vocabIds.isEmpty) continue;
        kanjiIds = [];
        grammarIds = [];
      } else if (category == LearningCategory.grammar) {
        if (grammarIds.isEmpty) continue;
        kanjiIds = [];
        vocabIds = [];
      } else if (category == LearningCategory.kanji) {
        if (kanjiIds.isEmpty) continue;
        vocabIds = [];
        grammarIds = [];
      }

      final lessonId = '${id}_${category.name}';
      lessons.add(
        Lesson(
          id: lessonId,
          title: item['title'] as String? ?? 'Bài học',
          kanjiIds: kanjiIds,
          vocabIds: vocabIds,
          grammarIds: grammarIds,
          level: parsedLevel,
          type: type,
          isCompleted: completedIds.contains(lessonId),
          isUnlocked: false,
        ),
      );
    }

    final sorted = _sortLessonsForGoal(lessons, goal);
    return _withUnlockState(sorted);
  }

  @override
  Future<void> setLessonCompletion(String id, bool isCompleted) async {
    if (isCompleted) {
      await _db
          .into(_db.lessonTable)
          .insertOnConflictUpdate(
            LessonTableCompanion.insert(id: id, isCompleted: const Value(true)),
          );
    } else {
      await (_db.delete(
        _db.lessonTable,
      )..where((table) => table.id.equals(id))).go();
    }
  }

  int _parseLevel(Object? levelValue) {
    if (levelValue is int) return levelValue;
    return int.tryParse(levelValue?.toString() ?? '') ?? 0;
  }

  List<Lesson> _withUnlockState(List<Lesson> lessons) {
    return [
      for (var i = 0; i < lessons.length; i++)
        lessons[i].copyWith(isUnlocked: i == 0 || lessons[i - 1].isCompleted),
    ];
  }

  List<Lesson> _sortLessonsForGoal(List<Lesson> lessons, LearningGoal goal) {
    int scoreFor(Lesson lesson) {
      switch (goal) {
        case LearningGoal.jlpt:
          return lesson.grammarIds.length + lesson.kanjiIds.length;
        case LearningGoal.conversation:
          return (lesson.vocabIds.length * 2) + lesson.grammarIds.length;
        case LearningGoal.reading:
          return (lesson.kanjiIds.length * 2) + lesson.vocabIds.length;
      }
    }

    final sorted = List<Lesson>.from(lessons);
    sorted.sort((a, b) => scoreFor(b).compareTo(scoreFor(a)));
    return sorted;
  }
}

List<Map<String, dynamic>> _decodePathData(String source) {
  final decoded = json.decode(source) as List<dynamic>;
  return decoded
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList(growable: false);
}
