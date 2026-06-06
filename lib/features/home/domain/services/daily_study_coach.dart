import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/features/learning/domain/entities/lesson.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';

enum DailyStudyActionType { review, lesson, placement, sentencePractice }

class DailyStudyPlan {
  final String title;
  final String subtitle;
  final String reason;
  final DailyStudyActionType actionType;
  final LearningCategory category;
  final int level;
  final int itemCount;

  const DailyStudyPlan({
    required this.title,
    required this.subtitle,
    required this.reason,
    required this.actionType,
    required this.category,
    required this.level,
    required this.itemCount,
  });
}

class DailyStudyCoach {
  const DailyStudyCoach();

  DailyStudyPlan recommend({
    required HomeProgress progress,
    required Map<LearningCategory, int> dueCounts,
    required List<Lesson> lessons,
    required LearningCategory defaultCategory,
    required int level,
    LearningCategory? weakestCategory,
  }) {
    final normalizedLevel = level.clamp(1, 5).toInt();
    final dueCategory = _reviewCategory(dueCounts, weakestCategory);
    if (dueCategory != null) {
      final count = dueCounts[dueCategory] ?? 0;
      return DailyStudyPlan(
        title: 'Ôn lại ${_categoryName(dueCategory).toLowerCase()}',
        subtitle: 'Một phiên ngắn để giữ trí nhớ ổn định.',
        reason: '$count thẻ đến hạn',
        actionType: DailyStudyActionType.review,
        category: dueCategory,
        level: normalizedLevel,
        itemCount: count,
      );
    }

    if (_hasNoLearningData(progress, lessons)) {
      return DailyStudyPlan(
        title: 'Định vị trình độ',
        subtitle: 'Làm bài kiểm tra ngắn để app chọn lộ trình phù hợp.',
        reason: 'Chưa có dữ liệu học',
        actionType: DailyStudyActionType.placement,
        category: LearningCategory.mixed,
        level: normalizedLevel,
        itemCount: 0,
      );
    }

    final openLesson = _firstOpenLesson(lessons);
    if (openLesson != null) {
      final category =
          _lessonCategory(openLesson, weakestCategory) ??
          (weakestCategory ?? defaultCategory);
      return DailyStudyPlan(
        title: 'Tiếp tục N$normalizedLevel',
        subtitle: openLesson.title,
        reason: weakestCategory == null
            ? 'Bài tiếp theo trong lộ trình'
            : '${_categoryName(weakestCategory)} là điểm yếu',
        actionType: DailyStudyActionType.lesson,
        category: category,
        level: normalizedLevel,
        itemCount: _lessonItemCount(openLesson, category),
      );
    }

    return DailyStudyPlan(
      title: 'Luyện câu ứng dụng',
      subtitle: 'Ôn lại ví dụ thật từ ngữ pháp đã có.',
      reason: 'Không còn thẻ đến hạn',
      actionType: DailyStudyActionType.sentencePractice,
      category: weakestCategory ?? defaultCategory,
      level: normalizedLevel,
      itemCount: 0,
    );
  }

  LearningCategory? _reviewCategory(
    Map<LearningCategory, int> dueCounts,
    LearningCategory? weakestCategory,
  ) {
    if (weakestCategory != null && (dueCounts[weakestCategory] ?? 0) > 0) {
      return weakestCategory;
    }

    final candidates =
        dueCounts.entries
            .where(
              (entry) => entry.key != LearningCategory.mixed && entry.value > 0,
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    if (candidates.isEmpty) return null;
    return candidates.first.key;
  }

  bool _hasNoLearningData(HomeProgress progress, List<Lesson> lessons) {
    final totalContent =
        progress.kanji.total +
        progress.vocabulary.total +
        progress.grammar.total;
    return totalContent == 0 && lessons.isEmpty;
  }

  Lesson? _firstOpenLesson(List<Lesson> lessons) {
    for (final lesson in lessons) {
      if (lesson.isUnlocked && !lesson.isCompleted) return lesson;
    }
    for (final lesson in lessons) {
      if (!lesson.isCompleted) return lesson;
    }
    return null;
  }

  LearningCategory? _lessonCategory(
    Lesson lesson,
    LearningCategory? preferred,
  ) {
    if (preferred != null && _lessonItemCount(lesson, preferred) > 0) {
      return preferred;
    }
    if (lesson.vocabIds.isNotEmpty) return LearningCategory.vocabulary;
    if (lesson.grammarIds.isNotEmpty) return LearningCategory.grammar;
    if (lesson.kanjiIds.isNotEmpty) return LearningCategory.kanji;
    return LearningCategory.mixed;
  }

  int _lessonItemCount(Lesson lesson, LearningCategory category) {
    return switch (category) {
      LearningCategory.vocabulary => lesson.vocabIds.length,
      LearningCategory.grammar => lesson.grammarIds.length,
      LearningCategory.kanji => lesson.kanjiIds.length,
      LearningCategory.mixed =>
        lesson.vocabIds.length +
            lesson.grammarIds.length +
            lesson.kanjiIds.length,
    };
  }

  String _categoryName(LearningCategory category) {
    return switch (category) {
      LearningCategory.vocabulary => 'Từ vựng',
      LearningCategory.grammar => 'Ngữ pháp',
      LearningCategory.kanji => 'Chữ Hán',
      LearningCategory.mixed => 'Tổng hợp',
    };
  }
}
