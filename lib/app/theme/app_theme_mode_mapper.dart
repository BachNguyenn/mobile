import 'package:flutter/material.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';

extension AppThemeModeMaterialMapper on AppThemeMode {
  ThemeMode get materialThemeMode {
    return switch (this) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }

  Brightness resolveBrightness(BuildContext context) {
    return switch (this) {
      AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
      AppThemeMode.light => Brightness.light,
      AppThemeMode.dark => Brightness.dark,
    };
  }
}
