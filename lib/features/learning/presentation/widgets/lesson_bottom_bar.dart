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
        QuizInputMode.typing => state.typedAnswer.trim().isNotEmpty,
      };

      return _BarSurface(
        child: _PrimaryLessonButton(
          icon: isStudy
              ? Icons.arrow_forward_rounded
              : Icons.fact_check_rounded,
          label: isStudy ? 'Tiếp tục' : 'Kiểm tra',
          color: AppColors.leafGreen,
          onPressed: canCheck ? onCheck : null,
        ),
      );
    }

    final isStudy = currentQ.inputMode == QuizInputMode.study;
    final color = isStudy
        ? AppColors.leafGreen
        : state.isCorrect
        ? AppColors.leafGreen
        : AppColors.terracotta;
    final message = isStudy
        ? 'Đã sẵn sàng luyện tập'
        : state.isCorrect
        ? 'Chính xác'
        : 'Chưa đúng';
    final icon = isStudy
        ? Icons.auto_stories_rounded
        : state.isCorrect
        ? Icons.check_circle_rounded
        : Icons.info_rounded;

    return _BarSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sp12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              border: Border.all(color: color.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: AppSpacing.sp8),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.bodyMBold.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp12),
          _PrimaryLessonButton(
            icon: Icons.arrow_forward_rounded,
            label: 'Tiếp tục',
            color: color,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _PrimaryLessonButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _PrimaryLessonButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.slateLight,
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.74),
          textStyle: AppTypography.bodyMBold.copyWith(
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          ),
        ),
      ),
    );
  }
}

class _BarSurface extends StatelessWidget {
  final Widget child;

  const _BarSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sp16,
          AppSpacing.sp12,
          AppSpacing.sp16,
          AppSpacing.sp16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: AppColors.slateLight.withValues(alpha: 0.32),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
