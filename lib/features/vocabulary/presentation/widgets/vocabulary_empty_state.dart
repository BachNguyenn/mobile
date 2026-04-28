import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class VocabularyEmptyState extends StatelessWidget {
  const VocabularyEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: AppColors.slateLight),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            'Không tìm thấy từ vựng nào.',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
          ),
        ],
      ),
    );
  }
}
