import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/providers/kanji_library_provider.dart';

class KanjiLevelSelector extends ConsumerWidget {
  const KanjiLevelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentFilter = ref.watch(kanjiLevelFilterProvider);
    final levels = [null, 5, 4, 3, 2, 1];
    final resolvedMoss = AppColors.resolve(AppColors.mossGreen, context);

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = currentFilter == level;
          final label = level == null ? 'Tất cả' : 'N$level';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(kanjiLevelFilterProvider.notifier).state = selected
                    ? level
                    : null;
              },
              selectedColor: resolvedMoss.withValues(alpha: 0.2),
              labelStyle: AppTypography.label.copyWith(
                color: isSelected
                    ? resolvedMoss
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                side: BorderSide(
                  color: isSelected
                      ? resolvedMoss
                      : theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.55,
                        ),
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
