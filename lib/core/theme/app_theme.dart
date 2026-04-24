import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// ThemeData tổng hợp cho Japandi Design System
///
/// Sử dụng: `MaterialApp(theme: AppTheme.light)`
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.mossGreen,
      primary: AppColors.mossGreen,
      onPrimary: AppColors.white,
      secondary: AppColors.terracotta,
      onSecondary: AppColors.white,
      surface: AppColors.cream,
      onSurface: AppColors.ink,
      error: AppColors.error,
      onError: AppColors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.slateGrey,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          color: AppColors.slateGrey,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          color: AppColors.slateGrey,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.slateMuted,
        ),
      ),

      // ─── AppBar ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.notoSerif(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),

      // ─── Bottom Navigation ───────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.mossGreen,
        unselectedItemColor: AppColors.slateLight,
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

      // ─── Card ────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: AppSpacing.elevationS,
        shadowColor: AppColors.ink.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── ElevatedButton ──────────────────────────────────
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

      // ─── OutlinedButton ──────────────────────────────────
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

      // ─── TextField / Input ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
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
          borderSide: BorderSide(color: AppColors.slateLight.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: AppColors.slateMuted,
        ),
        prefixIconColor: AppColors.slateMuted,
      ),

      // ─── Divider ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.slateLight,
        thickness: 0.5,
        space: 0,
      ),

      // ─── ProgressIndicator ───────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.mossGreen,
        linearTrackColor: AppColors.creamDark,
        linearMinHeight: 6,
      ),

      // ─── BottomSheet ─────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusL),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: AppColors.slateLight,
      ),
    );
  }
}
