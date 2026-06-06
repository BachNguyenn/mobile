import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/settings/data/repositories/shared_preferences_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads persisted current JLPT level', () async {
    SharedPreferences.setMockInitialValues({'settings.currentJlptLevel': 3});

    final settings = await SharedPreferencesSettingsRepository().load();

    expect(settings.currentJlptLevel, 3);
  });

  test('falls back to N5 for invalid persisted level', () async {
    SharedPreferences.setMockInitialValues({'settings.currentJlptLevel': 9});

    final settings = await SharedPreferencesSettingsRepository().load();

    expect(settings.currentJlptLevel, 5);
  });
}
