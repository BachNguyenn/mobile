import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('loads persisted current JLPT level', () async {
    SharedPreferences.setMockInitialValues({'settings.currentJlptLevel': 3});

    final settings = await AppSettingsStore.load();

    expect(settings.currentJlptLevel, 3);
  });

  test('falls back to N5 for invalid persisted level', () async {
    SharedPreferences.setMockInitialValues({'settings.currentJlptLevel': 9});

    final settings = await AppSettingsStore.load();

    expect(settings.currentJlptLevel, 5);
  });
}
