import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/lesson_controller.dart';
import '../handwriting_canvas.dart';

class LessonQuizContent extends StatelessWidget {
  final LessonState state;
  final Function(String) onSelectAnswer;
  final Function(List<List<Offset>>) onDrawingChanged;
  final VoidCallback onResetCanvas;
  final GlobalKey<HandwritingCanvasState> canvasKey;

  const LessonQuizContent({
    super.key,
    required this.state,
    required this.onSelectAnswer,
    required this.onDrawingChanged,
    required this.onResetCanvas,
    required this.canvasKey,
  });

  @override
  Widget build(BuildContext context) {
    final currentQ = state.questions[state.currentIndex];
    if (currentQ.type == QuizType.handwriting) {
      return _buildHandwritingQuiz(currentQ);
    } else {
      return _buildMultipleChoiceQuiz(currentQ);
    }
  }

  Widget _buildMultipleChoiceQuiz(QuizQuestion question) {
    final isMeaningQuiz = question.type == QuizType.meaning;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isMeaningQuiz ? 'Chọn nghĩa đúng' : 'Chọn chữ Kanji đúng',
          style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
        ),
        const SizedBox(height: AppSpacing.sp32),
        
        Expanded(
          flex: 2,
          child: Center(
            child: Text(
              isMeaningQuiz ? question.targetCard.kanji : question.targetCard.meanings,
              style: TextStyle(
                fontSize: isMeaningQuiz ? 100 : 32,
                fontWeight: FontWeight.bold,
                fontFamily: isMeaningQuiz ? 'Serif' : null,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: question.options.map((option) {
              final isSelected = state.selectedAnswerId == option.id;
              final isTarget = option.id == question.targetCard.id;
              
              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = AppColors.slateGrey;
              
              if (state.isAnswerChecked) {
                if (isTarget) {
                  bgColor = AppColors.mossGreen.withValues(alpha: 0.1);
                  borderColor = AppColors.mossGreen;
                  textColor = AppColors.mossGreen;
                } else if (isSelected && !isTarget) {
                  bgColor = AppColors.terracotta.withValues(alpha: 0.1);
                  borderColor = AppColors.terracotta;
                  textColor = AppColors.terracotta;
                }
              } else if (isSelected) {
                bgColor = AppColors.waterBlue.withValues(alpha: 0.1);
                borderColor = AppColors.waterBlue;
              }

              return GestureDetector(
                onTap: () => onSelectAnswer(option.id),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp16, horizontal: AppSpacing.sp20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Text(
                    isMeaningQuiz ? option.meanings : option.kanji,
                    style: AppTypography.bodyL.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: !isMeaningQuiz ? 'Serif' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHandwritingQuiz(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Viết chữ Kanji có nghĩa là:',
          style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
        ),
        const SizedBox(height: AppSpacing.sp16),
        Text(
          question.targetCard.meanings,
          style: AppTypography.headingL.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        Text(
          '${question.targetCard.onyomi} / ${question.targetCard.kunyomi}',
          style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sp24),
        
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.3), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  child: HandwritingCanvas(
                    key: canvasKey,
                    onDrawingChanged: onDrawingChanged,
                    onClear: onResetCanvas,
                  ),
                ),
              ),
              if (state.isAnswerChecked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            question.targetCard.kanji,
                            style: TextStyle(
                              fontSize: 120,
                              fontFamily: 'Serif',
                              color: state.isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                            ),
                          ),
                          if (state.recognizedText != null)
                            Text(
                              'Bạn đã viết: ${state.recognizedText}',
                              style: AppTypography.bodyM.copyWith(
                                color: state.isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.slateLight),
                  onPressed: () {
                    if (!state.isAnswerChecked) {
                      canvasKey.currentState?.clear();
                      onResetCanvas();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
