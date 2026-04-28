import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';

class KanjiJlptFilterDialog extends ConsumerWidget {
  const KanjiJlptFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      title: Text('Lọc theo trình độ JLPT', style: AppTypography.headingS),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterOption(context, ref, null, 'Tất cả'),
          _buildFilterOption(context, ref, 5, 'N5'),
          _buildFilterOption(context, ref, 4, 'N4'),
          _buildFilterOption(context, ref, 3, 'N3'),
          _buildFilterOption(context, ref, 2, 'N2'),
          _buildFilterOption(context, ref, 1, 'N1'),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    WidgetRef ref,
    int? level,
    String label,
  ) {
    final currentFilter = ref.watch(kanjiLevelFilterProvider);
    return ListTile(
      title: Text(label, style: AppTypography.bodyM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
      ),
      trailing: currentFilter == level
          ? const Icon(Icons.check_rounded, color: AppColors.mossGreen)
          : null,
      onTap: () {
        ref.read(kanjiLevelFilterProvider.notifier).state = level;
        Navigator.pop(context);
      },
    );
  }
}
