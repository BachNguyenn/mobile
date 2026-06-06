import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/features/settings/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('schedules daily reminder when reminder switch is enabled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settingsRepository = _FakeSettingsRepository(
      AppSettings.defaults.copyWith(
        dailyReminderEnabled: false,
        reminderHour: 7,
        reminderMinute: 30,
      ),
    );
    final notificationService = _FakeNotificationService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          settingsRepositoryProvider.overrideWithValue(settingsRepository),
          notificationServiceProvider.overrideWithValue(notificationService),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile).first);
    await tester.pumpAndSettle();

    expect(settingsRepository.settings.dailyReminderEnabled, isTrue);
    expect(notificationService.scheduledHour, 7);
    expect(notificationService.scheduledMinute, 30);
    expect(notificationService.cancelCount, 0);
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings settings;

  _FakeSettingsRepository(this.settings);

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings settings) async {
    this.settings = settings;
  }
}

class _FakeNotificationService extends NotificationService {
  int? scheduledHour;
  int? scheduledMinute;
  int cancelCount = 0;

  @override
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    scheduledHour = hour;
    scheduledMinute = minute;
  }

  @override
  Future<void> cancelDailyReminder() async {
    cancelCount++;
  }
}
