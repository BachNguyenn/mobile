import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color white = Color(0xFFFFFFFF);

  // Brand palette from the app icon.
  static const Color zenBlue = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF293156),
    darkColor: Color(0xFFAAB6E5),
  );
  static const Color navy = zenBlue;
  static const Color navyDark = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF151C36),
    darkColor: Color(0xFFF1F4FA),
  );
  static const Color navySoft = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF0F2F8),
    darkColor: Color(0xFF1F263F),
  );
  static const Color leafGreen = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF6E8E58),
    darkColor: Color(0xFFB9C9A7),
  );
  static const Color leafLight = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB9C9A7),
    darkColor: Color(0xFF6E8E58),
  );
  static const Color leafDark = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF49643D),
    darkColor: Color(0xFFD3E2C6),
  );
  static const Color cream = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFFFFF),
    darkColor: Color(0xFF111629),
  );
  static const Color creamDark = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFF2F4F0),
    darkColor: Color(0xFF22283A),
  );
  static const Color porcelain = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFBFCFA),
    darkColor: Color(0xFF0F1322),
  );

  // Backward-compatible aliases used across older screens.
  static const Color mossGreen = leafGreen;
  static const Color mossLight = leafLight;
  static const Color mossDark = leafDark;
  static const Color ink = navyDark;
  static const Color slateGrey = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF4E5668),
    darkColor: Color(0xFFC7D0DA),
  );
  static const Color slateMuted = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF8A92A3),
    darkColor: Color(0xFF97A3AF),
  );
  static const Color slateLight = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFD5DAE3),
    darkColor: Color(0xFF2A3146),
  );

  static const Color terracotta = Color(0xFFC47D5A);
  static const Color sakura = Color(0xFFE8B4B8);
  static const Color waterBlue = Color(0xFF6F9FD2);
  static const Color sunGold = Color(0xFFE0B34C);

  static const Color success = Color(0xFF5E9D70);
  static const Color warning = Color(0xFFE2A952);
  static const Color error = Color(0xFFCB6262);

  static const LinearGradient zenGardenGradient = LinearGradient(
    colors: [porcelain, cream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient zenGardenWarningGradient = LinearGradient(
    colors: [Color(0xFFFFF7EC), Color(0xFFF1E4D1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient mossGradient = LinearGradient(
    colors: [leafGreen, leafDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [navy, navyDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandLeafGradient = LinearGradient(
    colors: [navy, leafGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color gardenSand = Color(0xFFEDE5D2);
  static const Color gardenSandDark = Color(0xFFD7CEBB);
  static const Color bambooGreen = Color(0xFF8FBC8F);

  static const Color glassBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xB3FFFFFF),
    darkColor: Color(0xB3111629),
  );
  static const Color glassStroke = CupertinoDynamicColor.withBrightness(
    color: Color(0x8AFFFFFF),
    darkColor: Color(0x8A22283A),
  );
  static const Color glassShadow = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A151C36),
    darkColor: Color(0x1AF1F4FA),
  );

  static const Color gardenGlow = Color(0xFFE8D5A3);
  static const Color lightRay = Color(0xFFFFF8E7);
  static const Color petalGlow = Color(0xFFFFD6DC);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [navy, Color(0xFF1C274B), Color(0xFF425A51)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroWarningGradient = LinearGradient(
    colors: [Color(0xFF35263B), Color(0xFF5B3C45), Color(0xFF8B6542)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pageGradient = LinearGradient(
    colors: [cream, porcelain],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient gardenAtmosphere = LinearGradient(
    colors: [Color(0xFFF7F2E8), Color(0xFFEDE5D2), Color(0xFFE2D8C3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color navPillBg = CupertinoDynamicColor.withBrightness(
    color: Color(0xEBF0F2F8),
    darkColor: Color(0xEB1F263F),
  );

  static Color resolve(Color color, BuildContext context) {
    if (color is CupertinoDynamicColor) {
      return CupertinoDynamicColor.resolve(color, context);
    }
    return color;
  }

  static Color resolveWithAlpha(
    Color color,
    BuildContext context,
    double alpha,
  ) {
    return resolve(color, context).withValues(alpha: alpha);
  }

  static List<Color> resolveColors(List<Color> colors, BuildContext context) {
    return colors.map((color) => resolve(color, context)).toList();
  }

  /// Returns [shadow] only in light mode; dark backgrounds don't need drop shadows.
  static List<BoxShadow> softShadow(
    BuildContext context, {
    Color? color,
    double blurRadius = 12,
    Offset offset = const Offset(0, 6),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) return const [];
    return [
      BoxShadow(
        color: color ?? const Color(0x0E000000),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
}
