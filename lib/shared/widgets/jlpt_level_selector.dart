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
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth - (AppSpacing.sp16 * 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(levels.length, (index) {
                  final level = levels[index];
                  final isSelected = selectedLevel == level;
                  final label = level == null ? 'Tất cả' : 'N$level';

                  return GestureDetector(
                    onTap: () =>
                        onChanged(isSelected && level != null ? null : level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: index == levels.length - 1 ? 0 : AppSpacing.sp8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp20,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXL),
                        border: Border.all(
                          color: isSelected ? accentColor : borderColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: AppTypography.bodyMBold.copyWith(
                            color: isSelected
                                ? accentColor
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.55),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}
