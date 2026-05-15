import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

class JlptLevelSelector extends StatelessWidget {
  final int? selectedLevel;
  final ValueChanged<int?> onChanged;
  final Color accentColor;
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
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp8),
        itemBuilder: (context, index) {
          final level = levels[index];
          final selected = selectedLevel == level;
          final label = level == null ? 'Tất cả' : 'N$level';

          return ChoiceChip(
            selected: selected,
            label: Text(label),
            showCheckmark: false,
            onSelected: (_) =>
                onChanged(selected && level != null ? null : level),
            labelStyle: AppTypography.label.copyWith(
              color: selected ? AppColors.white : AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: AppColors.white,
            selectedColor: accentColor,
            side: BorderSide(
              color: selected
                  ? accentColor
                  : AppColors.slateLight.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            ),
          );
        },
      ),
    );
  }
}
