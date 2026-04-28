import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/vocabulary.dart';

class VocabularyListItem extends StatelessWidget {
  final Vocabulary vocabulary;

  const VocabularyListItem({
    super.key,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        side: BorderSide(color: AppColors.slateLight.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          vocabulary.word,
          style: AppTypography.headingS.copyWith(color: AppColors.ink),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vocabulary.reading,
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
            const SizedBox(height: 4),
            Text(
              vocabulary.meaning,
              style: AppTypography.bodyMBold.copyWith(color: AppColors.waterBlue),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.waterBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
          child: Text(
            'N${vocabulary.jlptLevel}',
            style: const TextStyle(
              color: AppColors.waterBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
