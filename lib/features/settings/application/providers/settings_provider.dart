import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('settingsRepositoryProvider must be overridden');
});

final settingsProvider =
    StateNotifierProvider<SettingsController, AsyncValue<AppSettings>>((ref) {
      return SettingsController(ref.watch(settingsRepositoryProvider));
    });

class SettingsController extends StateNotifier<AsyncValue<AppSettings>> {
  final SettingsRepository _repository;

  SettingsController(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final settings = await _repository.load();
    if (!mounted) return;
    state = AsyncValue.data(settings);
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

  Future<void> updateThemeMode(AppThemeMode mode) {
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

  Future<void> updateLearningGoal(LearningGoal goal) {
    return _update((settings) {
      return settings.copyWith(learningGoal: goal);
    });
  }

  Future<void> updateCurrentJlptLevel(int level) {
    return _update((settings) {
      return settings.copyWith(currentJlptLevel: level.clamp(1, 5).toInt());
    });
  }

  Future<void> _update(
    AppSettings Function(AppSettings settings) update,
  ) async {
    final current = state.value ?? AppSettings.defaults;
    final next = update(current);
    state = AsyncValue.data(next);
    await _repository.save(next);
  }
}
