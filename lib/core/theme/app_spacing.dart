import 'package:flutter/material.dart';

/// Spacing & Layout constants theo quy tắc 8dp Grid System
///
/// Mọi khoảng cách đều là bội số của 4dp (base unit),
/// ưu tiên sử dụng bội 8dp cho consistency.
///
/// Ví dụ sử dụng:
/// ```dart
/// Padding(padding: AppSpacing.paddingH24)      // Horizontal page margin
/// SizedBox(height: AppSpacing.sp16)             // Gap giữa elements
/// BorderRadius.circular(AppSpacing.radiusM)     // Card border radius
/// ```
abstract final class AppSpacing {
  // ─── Spacing Values ────────────────────────────────────────
  /// 4dp — Micro gap: icon-to-text, inline spacing
  static const double sp4 = 4.0;

  /// 8dp — Tight gap: giữa các inline elements
  static const double sp8 = 8.0;

  /// 12dp — Compact padding: chip internal, dense list
  static const double sp12 = 12.0;

  /// 16dp — Standard padding: card internal padding
  static const double sp16 = 16.0;

  /// 20dp — Section padding: giữa card title và content
  static const double sp20 = 20.0;

  /// 24dp — Page margin: horizontal padding của toàn trang
  static const double sp24 = 24.0;

  /// 32dp — Section gap: khoảng cách giữa các section lớn
  static const double sp32 = 32.0;

  /// 48dp — Large separator: khoảng cách giữa major sections
  static const double sp48 = 48.0;

  // ─── Border Radius ─────────────────────────────────────────
  /// 8dp — Extra small: tag, badge
  static const double radiusXS = 8.0;

  /// 12dp — Small: chip, small card
  static const double radiusS = 12.0;

  /// 16dp — Medium: main card, dialog
  static const double radiusM = 16.0;

  /// 24dp — Large: bottom sheet, modal
  static const double radiusL = 24.0;

  /// 32dp — Extra large: search bar, pill shape
  static const double radiusXL = 32.0;

  // ─── Elevation ─────────────────────────────────────────────
  /// Subtle shadow — card resting state
  static const double elevationS = 2.0;

  /// Medium shadow — card hover / pressed
  static const double elevationM = 4.0;

  /// Large shadow — modal, bottom sheet
  static const double elevationL = 8.0;

  // ─── Component Sizes ───────────────────────────────────────
  /// Bottom navigation bar height
  static const double bottomNavHeight = 64.0;

  /// SliverAppBar expanded height cho Zen Garden
  static const double zenHeaderExpandedHeight = 280.0;

  /// SliverAppBar collapsed height
  static const double zenHeaderCollapsedHeight = 64.0;

  /// Learning card height
  static const double learningCardHeight = 120.0;

  /// Icon container size trong learning card
  static const double iconContainerSize = 48.0;

  /// Progress bar height
  static const double progressBarHeight = 6.0;

  /// Search bar height
  static const double searchBarHeight = 48.0;

  // ─── Pre-built EdgeInsets ──────────────────────────────────
  /// Horizontal page margin: 24dp left + right
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: sp24);

  /// All-sides 16dp
  static const EdgeInsets paddingAll16 = EdgeInsets.all(sp16);

  /// All-sides 20dp
  static const EdgeInsets paddingAll20 = EdgeInsets.all(sp20);

  /// All-sides 24dp
  static const EdgeInsets paddingAll24 = EdgeInsets.all(sp24);

  /// Card internal padding: 20dp all sides
  static const EdgeInsets cardPadding = EdgeInsets.all(sp20);

  /// Section padding: 24dp horizontal, 16dp vertical
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: sp24,
    vertical: sp16,
  );
}
