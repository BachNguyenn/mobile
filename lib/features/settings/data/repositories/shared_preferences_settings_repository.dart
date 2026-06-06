import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const _dailyReminderEnabledKey = 'settings.dailyReminderEnabled';
  static const _reminderHourKey = 'settings.reminderHour';
  static const _reminderMinuteKey = 'settings.reminderMinute';
  static const _defaultLearningCategoryKey = 'settings.defaultLearningCategory';
  static const _hapticsEnabledKey = 'settings.hapticsEnabled';
  static const _themeModeKey = 'settings.themeMode';
  static const _appLanguageKey = 'settings.appLanguage';
  static const _fontScaleKey = 'settings.fontScale';
  static const _learningGoalKey = 'settings.learningGoal';
  static const _currentJlptLevelKey = 'settings.currentJlptLevel';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return fromPrefs(prefs);
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _dailyReminderEnabledKey,
      settings.dailyReminderEnabled,
    );
    await prefs.setInt(_reminderHourKey, settings.reminderHour);
    await prefs.setInt(_reminderMinuteKey, settings.reminderMinute);
    await prefs.setString(
      _defaultLearningCategoryKey,
      settings.defaultLearningCategory.name,
    );
    await prefs.setBool(_hapticsEnabledKey, settings.hapticsEnabled);
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setString(_appLanguageKey, settings.appLanguage);
    await prefs.setDouble(_fontScaleKey, settings.fontScale);
    await prefs.setString(_learningGoalKey, settings.learningGoal.name);
    await prefs.setInt(_currentJlptLevelKey, settings.currentJlptLevel);
  }

  static AppSettings fromPrefs(SharedPreferences prefs) {
    return AppSettings(
      dailyReminderEnabled:
          prefs.getBool(_dailyReminderEnabledKey) ??
          AppSettings.defaults.dailyReminderEnabled,
      reminderHour:
          prefs.getInt(_reminderHourKey) ?? AppSettings.defaults.reminderHour,
      reminderMinute:
          prefs.getInt(_reminderMinuteKey) ??
          AppSettings.defaults.reminderMinute,
      defaultLearningCategory: _categoryFromString(
        prefs.getString(_defaultLearningCategoryKey),
      ),
      hapticsEnabled:
          prefs.getBool(_hapticsEnabledKey) ??
          AppSettings.defaults.hapticsEnabled,
      themeMode: _themeModeFromString(prefs.getString(_themeModeKey)),
      appLanguage:
          prefs.getString(_appLanguageKey) ?? AppSettings.defaults.appLanguage,
      fontScale:
          prefs.getDouble(_fontScaleKey) ?? AppSettings.defaults.fontScale,
      learningGoal: _learningGoalFromString(prefs.getString(_learningGoalKey)),
      currentJlptLevel: _levelFromInt(prefs.getInt(_currentJlptLevelKey)),
    );
  }

  static LearningCategory _categoryFromString(String? value) {
    return LearningCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => AppSettings.defaults.defaultLearningCategory,
    );
  }

  static AppThemeMode _themeModeFromString(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppSettings.defaults.themeMode,
    );
  }

  static LearningGoal _learningGoalFromString(String? value) {
    return LearningGoal.values.firstWhere(
      (goal) => goal.name == value,
      orElse: () => AppSettings.defaults.learningGoal,
    );
  }

  static int _levelFromInt(int? value) {
    if (value == null) return AppSettings.defaults.currentJlptLevel;
    if (value < 1 || value > 5) return AppSettings.defaults.currentJlptLevel;
    return value;
  }
}
