import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF171A1F) : AppColors.cream;
    final card = isDark ? const Color(0xFF22262D) : AppColors.white;
    final text = isDark ? const Color(0xFFE8EDF2) : AppColors.ink;
    final body = isDark ? const Color(0xFFC7D0DA) : AppColors.slateGrey;
    final muted = isDark ? const Color(0xFF97A3AF) : AppColors.slateMuted;
    final border = isDark ? const Color(0xFF3A414A) : AppColors.slateLight;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mossGreen,
      primary: AppColors.mossGreen,
      onPrimary: AppColors.white,
      secondary: AppColors.terracotta,
      onSecondary: AppColors.white,
      surface: surface,
      onSurface: text,
      error: AppColors.error,
      onError: AppColors.white,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      cardColor: card,
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: body,
        ),
        bodyLarge: GoogleFonts.notoSans(fontSize: 16, color: body),
        bodyMedium: GoogleFonts.notoSans(fontSize: 14, color: body),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: AppColors.mossGreen,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: AppSpacing.elevationS,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mossGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp24,
            vertical: AppSpacing.sp16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mossGreen,
          side: const BorderSide(color: AppColors.mossGreen),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp24,
            vertical: AppSpacing.sp16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp16,
          vertical: AppSpacing.sp12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          borderSide: BorderSide(color: border.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSans(fontSize: 14, color: muted),
        prefixIconColor: muted,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.mossGreen,
        linearTrackColor: isDark
            ? const Color(0xFF2C3138)
            : AppColors.creamDark,
        linearMinHeight: 6,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: border,
      ),
    );
  }
}
