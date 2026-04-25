import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/kanji_card.dart';
import '../../screens/kanji_detail_screen.dart';

class KanjiGridItem extends StatelessWidget {
  final KanjiCard kanji;

  const KanjiGridItem({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KanjiDetailScreen(kanji: kanji),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusS,
          ),
          border: Border.all(
            color: AppColors.slateLight.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kanji.kanji,
              style: AppTypography.kanjiDisplay.copyWith(
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp4,
              ),
              child: Text(
                kanji.meanings.split(',').first,
                style: AppTypography.labelS.copyWith(
                  color: AppColors.slateMuted,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
