import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/domain/entities/lesson.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/navigation/daily_study_navigation.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class LessonResultScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final accuracy = totalQuestions == 0
        ? 0.0
        : correctAnswers / totalQuestions;
    final expGain = (correctAnswers * 8).clamp(0, 999);
    final resourceGain = (correctAnswers * 4).clamp(0, 999);
    final accuracyPercent = (accuracy * 100).round();
    final isStrong = accuracy >= 0.8;
    final accent = isStrong ? AppColors.sunGold : AppColors.leafGreen;
    final nextPlan = ref.watch(dailyStudyPlanProvider);

    final resolvedAccent = AppColors.resolve(accent, context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AppPageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sp20),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sp24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusL,
                            ),
                            border: Border.all(
                              color: resolvedAccent.withValues(alpha: 0.18),
                            ),
                            boxShadow: AppColors.softShadow(
                              context,
                              color: AppColors.resolve(AppColors.ink, context).withValues(alpha: 0.055),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: resolvedAccent.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isStrong
                                      ? Icons.emoji_events_rounded
                                      : Icons.auto_stories_rounded,
                                  color: resolvedAccent,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sp20),
                              Text(
                                'Hoàn thành bài học',
                                style: AppTypography.headingL.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sp8),
                              Text(
                                lesson.title,
                                style: AppTypography.bodyM.copyWith(
                                  color: AppColors.slateGrey,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sp24),
                              _ResultStat(
                                icon: Icons.check_circle_rounded,
                                label: 'Câu đúng',
                                value: '$correctAnswers/$totalQuestions',
                                color: AppColors.leafGreen,
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
                              const SizedBox(height: AppSpacing.sp12),
                              _ResultStat(
                                icon: Icons.spa_rounded,
                                label: 'Tài nguyên vườn',
                                value: '+$resourceGain nước/nắng',
                                color: AppColors.leafGreen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp16),
                        _NextActionCard(plan: nextPlan, ref: ref),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.route_rounded, size: 19),
                          label: const Text('Lộ trình'),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context, AppRoutes.garden());
                          },
                          icon: const Icon(Icons.spa_rounded, size: 19),
                          label: const Text('Khu vườn'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.leafGreen,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    final resolvedColor = AppColors.resolve(color, context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: resolvedColor, size: 21),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyM.copyWith(
                color: AppColors.resolve(AppColors.slateGrey, context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMBold.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextActionCard extends StatelessWidget {
  final AsyncValue<DailyStudyPlan> plan;
  final WidgetRef ref;

  const _NextActionCard({required this.plan, required this.ref});

  @override
  Widget build(BuildContext context) {
    final next = plan.value;
    if (next == null) {
      return const AppCard(
        child: SizedBox(
          height: 44,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          ),
        ),
      );
    }

    final leafGreen = AppColors.resolve(AppColors.leafGreen, context);

    return AppCard(
      color: leafGreen.withValues(alpha: 0.08),
      borderColor: leafGreen.withValues(alpha: 0.18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: leafGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: leafGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiếp theo',
                  style: AppTypography.label.copyWith(
                    color: leafGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  next.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMBold.copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
                Text(
                  next.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => openDailyStudyPlan(context, ref, next),
            icon: const Icon(Icons.arrow_forward_rounded),
            color: leafGreen,
          ),
        ],
      ),
    );
  }
}
