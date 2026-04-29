import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';

class ReviewAnswerOverlay extends StatelessWidget {
  final KanjiCard card;
  final String? recognizedText;

  const ReviewAnswerOverlay({
    super.key,
    required this.card,
    this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = recognizedText == card.kanji;

    return Positioned.fill(
      child: Container(
        color: Colors.white.withValues(alpha: 0.9),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                card.kanji,
                style: TextStyle(
                  fontSize: 120,
                  fontFamily: 'Serif',
                  color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                ),
              ),
              if (recognizedText != null)
                Text(
                  'Bạn viết: $recognizedText',
                  style: AppTypography.bodyM.copyWith(
                    color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
