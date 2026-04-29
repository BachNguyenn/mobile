import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/analytics_weekly_chart.dart';
import '../widgets/analytics_jlpt_progress.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Thống kê học tập', style: AppTypography.headingM),
      ),
      body: analyticsAsync.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.sp24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AnalyticsStatCard(
                      label: 'Đã học',
                      value: data.learned.toString(),
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp12),
                  Expanded(
                    child: AnalyticsStatCard(
                      label: 'Đang nhớ',
                      value: data.remembering.toString(),
                      color: AppColors.waterBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp12),
                  Expanded(
                    child: AnalyticsStatCard(
                      label: 'Chưa học',
                      value: data.notLearned.toString(),
                      color: AppColors.slateMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp32),
              Text(
                'Tiến độ 7 ngày qua',
                style: AppTypography.headingS.copyWith(color: AppColors.ink),
              ),
              const SizedBox(height: AppSpacing.sp16),
              AnalyticsWeeklyChart(weeklyData: data.weeklyData),
              const SizedBox(height: AppSpacing.sp32),
              AnalyticsJlptProgress(progress: data.jlptProgress),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
