import 'package:flutter/material.dart';
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
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  /// 24sp Bold — Heading lớn: "Hôm nay bạn muốn học gì?"
  static const TextStyle headingL = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.3,
  );

  /// 20sp SemiBold — Heading trung bình: section title
  static const TextStyle headingM = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.slateGrey,
    height: 1.35,
  );

  /// 18sp SemiBold — Heading nhỏ: card title
  static const TextStyle headingS = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.slateGrey,
    height: 1.35,
  );

  // ─── Body — Noto Sans JP ──────────────────────────────────

  /// 16sp Regular — Body text chính
  static const TextStyle bodyL = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 14sp Regular — Body text phụ
  static const TextStyle bodyM = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 14sp Medium — Body text nhấn mạnh
  static const TextStyle bodyMBold = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateGrey,
    height: 1.5,
  );

  /// 13sp Regular — Body text nhỏ
  static const TextStyle bodyS = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.slateGrey,
    height: 1.4,
  );

  // ─── Caption / Label ──────────────────────────────────────

  /// 13sp Regular — Caption, hint text
  static const TextStyle caption = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.slateMuted,
    height: 1.4,
  );

  /// 12sp Medium — Label, chip text, badge
  static const TextStyle label = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.4,
  );

  /// 11sp Medium — Micro label, nav bar label
  static const TextStyle labelS = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.3,
  );

  // ─── Special ──────────────────────────────────────────────

  /// 32sp Bold — Kanji display lớn
  static const TextStyle kanjiDisplay = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// 48sp Bold — Kanji hero (detail screen)
  static const TextStyle kanjiHero = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.1,
  );

  /// 16sp — Japanese motivational text
  static const TextStyle japaneseQuote = TextStyle(
    fontFamily: 'NotoSerif',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.slateMuted,
    height: 1.6,
    letterSpacing: 1.2,
  );

  /// 24sp Bold — Số thống kê (streak count, percentage)
  static const TextStyle statNumber = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  /// 14sp Medium — Stat label
  static const TextStyle statLabel = TextStyle(
    fontFamily: 'NotoSansJP',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.slateMuted,
    height: 1.3,
  );
}
