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
    final surface = isDark ? const Color(0xFF111629) : AppColors.cream;
    final card = isDark ? const Color(0xFF1B2136) : AppColors.white;
    final text = isDark ? const Color(0xFFF1F4FA) : AppColors.ink;
    final body = isDark ? const Color(0xFFC7D0DA) : AppColors.slateGrey;
    final muted = isDark ? const Color(0xFF97A3AF) : AppColors.slateMuted;
    final border = isDark ? const Color(0xFF30384E) : AppColors.slateLight;
    final primary = isDark ? const Color(0xFFAAB6E5) : AppColors.zenBlue;
    final secondary = isDark ? AppColors.leafLight : AppColors.leafGreen;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.zenBlue,
      primary: primary,
      onPrimary: AppColors.white,
      secondary: secondary,
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
      textTheme: GoogleFonts.notoSansJpTextTheme().copyWith(
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
        bodyLarge: GoogleFonts.notoSansJp(fontSize: 16, color: body),
        bodyMedium: GoogleFonts.notoSansJp(fontSize: 14, color: body),
        labelSmall: GoogleFonts.notoSansJp(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? surface : AppColors.porcelain,
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
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF20263B) : AppColors.ink,
        contentTextStyle: GoogleFonts.notoSansJp(
          fontSize: 14,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp20,
            vertical: AppSpacing.sp12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          ),
          textStyle: GoogleFonts.notoSansJp(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
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
          backgroundColor: primary,
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
          foregroundColor: primary,
          side: BorderSide(color: primary),
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
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSans(fontSize: 14, color: muted),
        prefixIconColor: muted,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: isDark
            ? const Color(0xFF2A3044)
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
