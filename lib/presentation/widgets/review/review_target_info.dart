import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/kanji_card.dart';

class ReviewTargetInfo extends StatelessWidget {
  final KanjiCard card;

  const ReviewTargetInfo({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            card.meanings,
            style: AppTypography.headingL.copyWith(color: AppColors.ink),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            '${card.onyomi} / ${card.kunyomi}',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
        ],
      ),
    );
  }
}
