import 'package:flutter/material.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:mobile/features/garden/presentation/screens/garden_screen.dart';
import 'package:mobile/features/grammar/presentation/screens/grammar_analysis_screen.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/presentation/screens/learning_path_screen.dart';
import 'package:mobile/features/learning/presentation/screens/lesson_detail_screen.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/screens/review_screen.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';

abstract final class AppRoutes {
  static MaterialPageRoute<void> analytics() {
    return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
  }

  static MaterialPageRoute<void> garden() {
    return MaterialPageRoute(builder: (_) => const GardenScreen());
  }

  static MaterialPageRoute<void> grammarAnalysis() {
    return MaterialPageRoute(builder: (_) => const GrammarAnalysisScreen());
  }

  static MaterialPageRoute<void> learningPath({
    bool isNavBarMode = false,
    LearningCategory? initialCategory,
  }) {
    return MaterialPageRoute(
      builder: (_) => LearningPathScreen(
        isNavBarMode: isNavBarMode,
        initialCategory: initialCategory,
      ),
    );
  }

  static MaterialPageRoute<void> lessonDetail(Lesson lesson) {
    return MaterialPageRoute(
      builder: (_) => LessonDetailScreen(lesson: lesson),
    );
  }

  static MaterialPageRoute<void> review(List<ReviewItem> items) {
    return MaterialPageRoute(builder: (_) => ReviewScreen(items: items));
  }

  static MaterialPageRoute<void> settings() {
    return MaterialPageRoute(builder: (_) => const SettingsScreen());
  }
}
