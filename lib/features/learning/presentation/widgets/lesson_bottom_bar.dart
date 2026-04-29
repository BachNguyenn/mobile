import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/presentation/providers/lesson_controller.dart';

class LessonBottomBar extends StatelessWidget {
  final LessonState state;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const LessonBottomBar({
    super.key,
    required this.state,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final currentQ = state.questions[state.currentIndex];

    if (!state.isAnswerChecked) {
      final isStudy = currentQ.inputMode == QuizInputMode.study;
      final canCheck = switch (currentQ.inputMode) {
        QuizInputMode.study => true,
        QuizInputMode.handwriting => state.currentStrokes.isNotEmpty,
        QuizInputMode.multipleChoice => state.selectedAnswer != null,
      };

      return _BarSurface(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canCheck ? onCheck : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.slateLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              ),
              elevation: 0,
            ),
            child: Text(
              isStudy ? 'Tiếp tục' : 'Kiểm tra',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final isStudy = currentQ.inputMode == QuizInputMode.study;
    final color = isStudy
        ? AppColors.mossGreen
        : state.isCorrect
            ? AppColors.mossGreen
            : AppColors.terracotta;
    final message = isStudy
        ? 'Đã hiểu!'
        : state.isCorrect
            ? 'Chính xác!'
            : 'Chưa đúng';
    final icon = isStudy
        ? Icons.auto_stories_rounded
        : state.isCorrect
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    return _BarSurface(
      backgroundColor: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.25),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.headingM.copyWith(color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarSurface extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  const _BarSurface({
    required this.child,
    this.backgroundColor = AppColors.white,
    this.borderColor = const Color(0xFFE7E2DA),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp24),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: child,
    );
  }
}
