import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/lesson_controller.dart';

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
    if (!state.isAnswerChecked) {
      final currentQ = state.questions[state.currentIndex];
      final canCheck = currentQ.type == QuizType.handwriting 
          ? state.currentStrokes.isNotEmpty 
          : state.selectedAnswerId != null;

      return Container(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canCheck ? onCheck : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mossGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
              elevation: 0,
            ),
            child: const Text('Kiểm tra', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      );
    }

    final color = state.isCorrect ? AppColors.mossGreen : AppColors.terracotta;
    final message = state.isCorrect ? 'Chính xác!' : 'Chưa đúng rồi!';
    final icon = state.isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(top: BorderSide(color: color.withValues(alpha: 0.3))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: AppSpacing.sp12),
              Text(message, style: AppTypography.headingM.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: AppSpacing.sp24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusL)),
                elevation: 0,
              ),
              child: const Text('Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
