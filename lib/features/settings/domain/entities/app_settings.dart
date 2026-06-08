import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';

class AppSettings {
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final LearningCategory defaultLearningCategory;
  final bool hapticsEnabled;
  final AppThemeMode themeMode;
  final String appLanguage;
  final double fontScale;
  final LearningGoal learningGoal;
  final int currentJlptLevel;

  const AppSettings({
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.defaultLearningCategory,
    required this.hapticsEnabled,
    required this.themeMode,
    required this.appLanguage,
    required this.fontScale,
    required this.learningGoal,
    required this.currentJlptLevel,
  });

  static const defaults = AppSettings(
    dailyReminderEnabled: true,
    reminderHour: 20,
    reminderMinute: 0,
    defaultLearningCategory: LearningCategory.mixed,
    hapticsEnabled: true,
    themeMode: AppThemeMode.system,
    appLanguage: 'vi',
    fontScale: 0.9,
    learningGoal: LearningGoal.jlpt,
    currentJlptLevel: 5,
  );

  AppSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    LearningCategory? defaultLearningCategory,
    bool? hapticsEnabled,
    AppThemeMode? themeMode,
    String? appLanguage,
    double? fontScale,
    LearningGoal? learningGoal,
    int? currentJlptLevel,
  }) {
    return AppSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      defaultLearningCategory:
          defaultLearningCategory ?? this.defaultLearningCategory,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      themeMode: themeMode ?? this.themeMode,
      appLanguage: appLanguage ?? this.appLanguage,
      fontScale: fontScale ?? this.fontScale,
      learningGoal: learningGoal ?? this.learningGoal,
      currentJlptLevel: currentJlptLevel ?? this.currentJlptLevel,
    );
  }
}
