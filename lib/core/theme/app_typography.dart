import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography presets cho Japandi Design System
///
/// Sử dụng 2 font:
/// - **Noto Serif** — cho heading, display, tạo cảm giác truyền thống
/// - **Noto Sans JP** — cho body, caption, dễ đọc trên mobile
///
/// Naming convention: `[weight][size]` hoặc `[purpose]`
abstract final class AppTypography {
  // ─── Display / Heading — Noto Serif ────────────────────────

  /// 28sp Bold — Tiêu đề trang chính (ít dùng)
  static TextStyle displayLarge = GoogleFonts.notoSerif(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  /// 24sp Bold — Heading lớn: "Hôm nay bạn muốn học gì?"
  static TextStyle headingL = GoogleFonts.notoSerif(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  /// 20sp SemiBold — Heading trung bình: section title
  static TextStyle headingM = GoogleFonts.notoSerif(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.slateGrey,
    height: 1.35,
  );

  /// 18sp SemiBold — Heading nhỏ: card title
  static TextStyle headingS = GoogleFonts.notoSerif(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.slateGrey,
    height: 1.35,
  );

  // ─── Body — Noto Sans JP ──────────────────────────────────

  /// 16sp Regular — Body text chính
  static TextStyle bodyL = GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 14sp Regular — Body text phụ
  static TextStyle bodyM = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 14sp Medium — Body text nhấn mạnh
  static TextStyle bodyMBold = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 13sp Regular — Body text nhỏ
  static TextStyle bodyS = GoogleFonts.notoSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.4,
  );

  // ─── Caption / Label ──────────────────────────────────────

  /// 13sp Regular — Caption, hint text
  static TextStyle caption = GoogleFonts.notoSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.slateMuted,
    height: 1.4,
  );

  /// 12sp Medium — Label, chip text, badge
  static TextStyle label = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.4,
  );

  /// 11sp Medium — Micro label, nav bar label
  static TextStyle labelS = GoogleFonts.notoSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.3,
  );

  // ─── Special ──────────────────────────────────────────────

  /// 32sp Bold — Kanji display lớn
  static TextStyle kanjiDisplay = GoogleFonts.notoSerif(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// 48sp Bold — Kanji hero (detail screen)
  static TextStyle kanjiHero = GoogleFonts.notoSerif(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.1,
  );

  /// 16sp — Japanese motivational text
  static TextStyle japaneseQuote = GoogleFonts.notoSerif(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.slateMuted,
    height: 1.6,
    letterSpacing: 1.2,
  );

  /// 24sp Bold — Số thống kê (streak count, percentage)
  static TextStyle statNumber = GoogleFonts.notoSans(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// 14sp Medium — Stat label
  static TextStyle statLabel = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.3,
  );
}
