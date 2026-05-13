import 'package:flutter/material.dart';

/// Japandi (Japanese + Scandinavian) Minimalism Color Palette
///
/// Thiết kế theo triết lý "tĩnh lặng nhưng hiện đại":
/// - Nền ấm (Cream) gợi cảm giác giấy washi truyền thống
/// - Xanh rêu (Moss) làm điểm nhấn tự nhiên
/// - Xám đá (Slate) cho typography rõ ràng
/// - Accent ấm (Terracotta, Sakura) cho gamification
abstract final class AppColors {
  // ─── Background ────────────────────────────────────────────
  /// Nền chính — giấy washi ấm
  static const Color cream = Color(0xFFFFFFFF);

  /// Nền phụ — card surface, section background
  static const Color creamDark = Color(0xFFF0EDE8);

  /// Nền xanh đậm — theo màu của App Icon
  static const Color zenBlue = Color(0xFF293156);

  // ─── Primary — Moss Green ──────────────────────────────────
  /// Primary chính — nút, accent, progress bar
  static const Color mossGreen = Color(0xFF7A8B6F);

  /// Primary light — hover state, selected tab
  static const Color mossLight = Color(0xFFA3B18A);

  /// Primary dark — text trên nền sáng, icon active
  static const Color mossDark = Color(0xFF5C6B52);

  // ─── Text — Slate Grey ─────────────────────────────────────
  /// Text đậm — heading, title, emphasis
  static const Color ink = Color(0xFF2D3748);

  /// Text chính — body, subtitle
  static const Color slateGrey = Color(0xFF4A5568);

  /// Text phụ — caption, hint, placeholder
  static const Color slateMuted = Color(0xFF8896A4);

  /// Border, divider, disabled state
  static const Color slateLight = Color(0xFFCBD5E0);

  // ─── Surface ───────────────────────────────────────────────
  /// Card surface, overlay, bottom sheet
  static const Color white = Color(0xFFFFFFFF);

  // ─── Accent ────────────────────────────────────────────────
  /// Accent ấm — streak fire, warning nhẹ
  static const Color terracotta = Color(0xFFC47D5A);

  /// Accent mềm — badge, notification, sakura particles
  static const Color sakura = Color(0xFFE8B4B8);

  /// Accent xanh dương nhẹ — water indicator
  static const Color waterBlue = Color(0xFF7FACD6);

  /// Accent vàng — sunlight indicator, star
  static const Color sunGold = Color(0xFFE2B44F);

  // ─── Semantic ──────────────────────────────────────────────
  /// Trạng thái thành công
  static const Color success = Color(0xFF68A87A);

  /// Trạng thái cảnh báo
  static const Color warning = Color(0xFFE2A952);

  /// Trạng thái lỗi
  static const Color error = Color(0xFFCB6B6B);

  // ─── Gradient Presets ──────────────────────────────────────
  /// Gradient cho Zen Garden header — trạng thái bình thường
  static const LinearGradient zenGardenGradient = LinearGradient(
    colors: [cream, creamDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradient cho Zen Garden header — trạng thái cảnh báo (nhiều thẻ quá hạn)
  static const LinearGradient zenGardenWarningGradient = LinearGradient(
    colors: [Color(0xFFFDF6ED), Color(0xFFF5EDDF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradient cho Moss Green button / card
  static const LinearGradient mossGradient = LinearGradient(
    colors: [mossGreen, mossDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Garden 2D Palette ─────────────────────────────────────
  /// Sand ground color cho 2D garden
  static const Color gardenSand = Color(0xFFF0EAD6);

  /// Sand dark — raked pattern lines
  static const Color gardenSandDark = Color(0xFFDDD5C0);

  /// Bamboo green
  static const Color bambooGreen = Color(0xFF8FBC8F);

  // ─── Glassmorphism ──────────────────────────────────────────
  /// Frosted glass background
  static Color get glassBg => white.withValues(alpha: 0.55);

  /// Glass border / stroke
  static Color get glassStroke => white.withValues(alpha: 0.35);

  /// Glass shadow
  static Color get glassShadow => ink.withValues(alpha: 0.08);

  // ─── Ambient / Glow ────────────────────────────────────────
  /// Golden glow for ambient particles
  static const Color gardenGlow = Color(0xFFE8D5A3);

  /// Soft warm light ray
  static const Color lightRay = Color(0xFFFFF8E7);

  /// Petal pink glow
  static const Color petalGlow = Color(0xFFFFD6DC);

  // ─── Gradient Presets (Enhanced) ───────────────────────────
  /// Premium hero header gradient — deeper wash
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFBF9F6), Color(0xFFF5F0E8), Color(0xFFEFE8DA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Hero header warning state
  static const LinearGradient heroWarningGradient = LinearGradient(
    colors: [Color(0xFFFDF6ED), Color(0xFFF8EDE0), Color(0xFFF2E4D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Garden atmospheric gradient
  static const LinearGradient gardenAtmosphere = LinearGradient(
    colors: [Color(0xFFF7F2E8), Color(0xFFF0EAD6), Color(0xFFE8E0CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Nav Bar ───────────────────────────────────────────────
  /// Active pill background
  static Color get navPillBg => mossGreen.withValues(alpha: 0.12);
}
