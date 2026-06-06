import 'package:mobile/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
