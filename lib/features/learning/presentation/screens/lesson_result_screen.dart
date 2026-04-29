import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/lesson.dart';

class LessonResultScreen extends StatelessWidget {
  final Lesson lesson;
  final int correctAnswers;
  final int totalQuestions;

  const LessonResultScreen({
    super.key,
    required this.lesson,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = totalQuestions == 0 ? 0.0 : correctAnswers / totalQuestions;
    final expGain = (correctAnswers * 8).clamp(0, 999);
    final accuracyPercent = (accuracy * 100).round();

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sp24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                accuracy >= 0.8
                    ? Icons.emoji_events_rounded
                    : Icons.auto_stories_rounded,
                color: accuracy >= 0.8 ? AppColors.sunGold : AppColors.mossGreen,
                size: 76,
              ),
              const SizedBox(height: AppSpacing.sp20),
              Text(
                'Hoàn thành bài học',
                style: AppTypography.headingL.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                lesson.title,
                style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sp32),
              _ResultStat(
                icon: Icons.check_circle_rounded,
                label: 'Câu đúng',
                value: '$correctAnswers/$totalQuestions',
                color: AppColors.mossGreen,
              ),
              const SizedBox(height: AppSpacing.sp12),
              _ResultStat(
                icon: Icons.insights_rounded,
                label: 'Độ chính xác',
                value: '$accuracyPercent%',
                color: AppColors.waterBlue,
              ),
              const SizedBox(height: AppSpacing.sp12),
              _ResultStat(
                icon: Icons.local_florist_rounded,
                label: 'Kinh nghiệm',
                value: '+$expGain EXP',
                color: AppColors.sunGold,
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossGreen,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    ),
                  ),
                  child: const Text(
                    'Về lộ trình',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}
