import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool dailyReminderEnabled;
  final int reminderHour;
  final int reminderMinute;
  final LearningCategory defaultLearningCategory;
  final bool hapticsEnabled;
  final ThemeMode themeMode;
  final String appLanguage;
  final double fontScale;

  const AppSettings({
    required this.dailyReminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.defaultLearningCategory,
    required this.hapticsEnabled,
    required this.themeMode,
    required this.appLanguage,
    required this.fontScale,
  });

  static const defaults = AppSettings(
    dailyReminderEnabled: true,
    reminderHour: 20,
    reminderMinute: 0,
    defaultLearningCategory: LearningCategory.mixed,
    hapticsEnabled: true,
    themeMode: ThemeMode.system,
    appLanguage: 'vi',
    fontScale: 1.0,
  );

  AppSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    LearningCategory? defaultLearningCategory,
    bool? hapticsEnabled,
    ThemeMode? themeMode,
    String? appLanguage,
    double? fontScale,
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
    );
  }
}

abstract final class AppSettingsStore {
  static const _dailyReminderEnabledKey = 'settings.dailyReminderEnabled';
  static const _reminderHourKey = 'settings.reminderHour';
  static const _reminderMinuteKey = 'settings.reminderMinute';
  static const _defaultLearningCategoryKey = 'settings.defaultLearningCategory';
  static const _hapticsEnabledKey = 'settings.hapticsEnabled';
  static const _themeModeKey = 'settings.themeMode';
  static const _appLanguageKey = 'settings.appLanguage';
  static const _fontScaleKey = 'settings.fontScale';

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return fromPrefs(prefs);
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
    );
  }

  static Future<void> save(AppSettings settings) async {
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
  }

  static LearningCategory _categoryFromString(String? value) {
    return LearningCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => AppSettings.defaults.defaultLearningCategory,
    );
  }

  static ThemeMode _themeModeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppSettings.defaults.themeMode,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>((ref) {
      return SettingsController();
    });

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsController() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = AsyncValue.data(await AppSettingsStore.load());
  }

  Future<void> updateDailyReminderEnabled(bool enabled) {
    return _update((settings) {
      return settings.copyWith(dailyReminderEnabled: enabled);
    });
  }

  Future<void> updateReminderTime({required int hour, required int minute}) {
    return _update((settings) {
      return settings.copyWith(reminderHour: hour, reminderMinute: minute);
    });
  }

  Future<void> updateDefaultLearningCategory(LearningCategory category) {
    return _update((settings) {
      return settings.copyWith(defaultLearningCategory: category);
    });
  }

  Future<void> updateHapticsEnabled(bool enabled) {
    return _update((settings) {
      return settings.copyWith(hapticsEnabled: enabled);
    });
  }

  Future<void> updateThemeMode(ThemeMode mode) {
    return _update((settings) {
      return settings.copyWith(themeMode: mode);
    });
  }

  Future<void> updateAppLanguage(String language) {
    return _update((settings) {
      return settings.copyWith(appLanguage: language);
    });
  }

  Future<void> updateFontScale(double scale) {
    return _update((settings) {
      return settings.copyWith(fontScale: scale);
    });
  }

  Future<void> _update(
    AppSettings Function(AppSettings settings) update,
  ) async {
    final current = state.valueOrNull ?? AppSettings.defaults;
    final next = update(current);
    state = AsyncValue.data(next);
    await AppSettingsStore.save(next);
  }
}
