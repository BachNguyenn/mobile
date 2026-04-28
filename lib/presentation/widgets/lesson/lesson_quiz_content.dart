import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/lesson_controller.dart';
import '../../../features/kanji/domain/entities/kanji_card.dart';
import '../../../features/grammar/domain/entities/grammar_point.dart';
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
    
    switch (currentQ.type) {
      case QuizType.handwriting:
        return _buildHandwritingQuiz(currentQ);
      case QuizType.grammarStudy:
        return _buildGrammarStudy(currentQ);
      default:
        return _buildMultipleChoiceQuiz(currentQ);
    }
  }

  Widget _buildGrammarStudy(QuizQuestion question) {
    final grammar = question.originalData as GrammarPoint;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Cấu trúc Ngữ pháp',
            style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: AppSpacing.sp24),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.sp20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  grammar.title,
                  style: AppTypography.headingL.copyWith(color: AppColors.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  grammar.formation,
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.mossGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.sp24),
          
          Text(
            'Giải thích',
            style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: 8),
          Text(
            grammar.longExplanation,
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
          
          const SizedBox(height: AppSpacing.sp24),
          
          Text(
            'Ví dụ',
            style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: AppSpacing.sp12),
          
          ...grammar.examples.map((ex) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
            padding: const EdgeInsets.all(AppSpacing.sp16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ex.jp,
                  style: AppTypography.bodyL.copyWith(
                    color: AppColors.ink,
                    fontFamily: 'Serif',
                  ),
                ),
                Text(
                  ex.romaji,
                  style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  ex.en,
                  style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuiz(QuizQuestion question) {
    String headerText;
    switch (question.type) {
      case QuizType.meaning: headerText = 'Chọn nghĩa đúng của chữ Hán'; break;
      case QuizType.kanji: headerText = 'Chọn chữ Kanji đúng'; break;
      case QuizType.vocabMeaning: headerText = 'Chọn nghĩa của từ vựng'; break;
      case QuizType.vocabReading: headerText = 'Chọn cách đọc đúng'; break;
      default: headerText = 'Chọn đáp án đúng';
    }

    final isBigText = question.type == QuizType.meaning || question.type == QuizType.vocabMeaning;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            headerText,
            style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: AppSpacing.sp32),
          
          Center(
            child: Text(
              question.prompt,
              style: TextStyle(
                fontSize: isBigText ? 80 : 32,
                fontWeight: FontWeight.bold,
                fontFamily: isBigText ? 'Serif' : null,
                color: AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sp32),
          
          Column(
            children: question.options.map((option) {
              final isSelected = state.selectedAnswer == option;
              final isCorrect = option == question.answer;
              
              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = AppColors.slateGrey;
              
              if (state.isAnswerChecked) {
                if (isCorrect) {
                  bgColor = AppColors.mossGreen.withValues(alpha: 0.1);
                  borderColor = AppColors.mossGreen;
                  textColor = AppColors.mossGreen;
                } else if (isSelected && !isCorrect) {
                  bgColor = AppColors.terracotta.withValues(alpha: 0.1);
                  borderColor = AppColors.terracotta;
                  textColor = AppColors.terracotta;
                }
              } else if (isSelected) {
                bgColor = AppColors.waterBlue.withValues(alpha: 0.1);
                borderColor = AppColors.waterBlue;
              }

              return GestureDetector(
                onTap: () => onSelectAnswer(option),
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
                    option,
                    style: AppTypography.bodyL.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: question.type == QuizType.kanji ? 'Serif' : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandwritingQuiz(QuizQuestion question) {
    final kanji = question.originalData as KanjiCard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Viết chữ Kanji có nghĩa là:',
          style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
        ),
        const SizedBox(height: AppSpacing.sp16),
        Text(
          question.prompt,
          style: AppTypography.headingL.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        Text(
          '${kanji.onyomi} / ${kanji.kunyomi}',
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
                            question.answer,
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
