import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Shared JLPT Level Selector cho tất cả library screens.
///
/// Thay thế 3 bản copy riêng lẻ trong Vocabulary, Kanji, Grammar
/// bằng một widget dùng chung, chỉ khác `accentColor`.
///
/// ```dart
/// JlptLevelSelector(
///   selectedLevel: currentFilter,
///   accentColor: AppColors.waterBlue,
///   onChanged: (level) => ref.read(provider.notifier).state = level,
/// )
/// ```
class JlptLevelSelector extends StatelessWidget {
  /// Level hiện tại đang chọn. `null` = "Tất cả".
  final int? selectedLevel;

  /// Callback khi user chọn level. Trả `null` nếu chọn "Tất cả".
  final ValueChanged<int?> onChanged;

  /// Accent color cho chip khi selected.
  final Color accentColor;

  /// Các JLPT levels hiển thị. Mặc định: [null, 5, 4, 3, 2, 1].
  final List<int?> levels;

  const JlptLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    required this.accentColor,
    this.levels = const [null, 5, 4, 3, 2, 1],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.3);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = selectedLevel == level;
          final label = level == null ? 'Tất cả' : 'N$level';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: accentColor.withValues(alpha: 0.2),
              labelStyle: AppTypography.label.copyWith(
                color: isSelected ? accentColor : theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) => onChanged(selected ? level : null),
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                side: BorderSide(
                  color: isSelected ? accentColor : borderColor,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
