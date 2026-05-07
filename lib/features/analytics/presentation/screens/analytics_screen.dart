import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../grammar/presentation/providers/grammar_library_provider.dart';
import '../../../kanji/presentation/providers/kanji_library_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/analytics_heatmap.dart';
import '../widgets/analytics_jlpt_progress.dart';
import '../../../review/domain/entities/review_item.dart';
import '../../../vocabulary/presentation/providers/vocabulary_library_provider.dart';
import '../../../../presentation/navigation/app_routes.dart';
import '../../../../shared/widgets/app_page_background.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê học tập', style: AppTypography.headingM),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
      ),
      body: analyticsAsync.when(
        data: (data) => AppPageBackground(
          child: SingleChildScrollView(
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
                const SizedBox(height: AppSpacing.sp16),
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Lượt ôn 30 ngày',
                        value: data.reviewsLast30Days.toString(),
                        color: AppColors.mossGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Ngày học/30',
                        value: data.activeDaysLast30Days.toString(),
                        color: AppColors.sunGold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Tỉ lệ nhớ',
                        value: '${(data.successRateLast30Days * 100).round()}%',
                        color: AppColors.terracotta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                Row(
                  children: [
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Tỉ lệ nhớ D1',
                        value: '${(data.d1Retention * 100).round()}%',
                        color: AppColors.mossGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Tỉ lệ nhớ D7',
                        value: '${(data.d7Retention * 100).round()}%',
                        color: AppColors.waterBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(
                      child: AnalyticsStatCard(
                        label: 'Hoàn thành lộ trình',
                        value: '${(data.lessonCompletionRate * 100).round()}%',
                        color: AppColors.sunGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp32),
                Text(
                  'Mức độ hoạt động',
                  style: AppTypography.headingS.copyWith(color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.sp16),
                AnalyticsHeatmap(heatmapData: data.heatmapData),
                const SizedBox(height: AppSpacing.sp32),
                AnalyticsJlptProgress(progress: data.jlptProgress),
                const SizedBox(height: AppSpacing.sp24),
                _WeakAreaInsightCard(
                  area: data.weakestArea,
                  areaType: data.weakestAreaType,
                  successRate: data.weakestAreaSuccessRate,
                  onPracticeNow: () =>
                      _openWeakAreaReview(context, ref, data.weakestAreaType),
                ),
                const SizedBox(height: AppSpacing.sp16),
                _RetentionInsightCard(
                  dropoutPoint: data.dropoutPoint,
                  cohortByLevel: data.cohortByLevel,
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}

class _RetentionInsightCard extends StatelessWidget {
  final String dropoutPoint;
  final Map<String, double> cohortByLevel;

  const _RetentionInsightCard({
    required this.dropoutPoint,
    required this.cohortByLevel,
  });

  @override
  Widget build(BuildContext context) {
    final sortedKeys = cohortByLevel.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tỉ lệ nhớ theo cấp độ',
            style: AppTypography.headingS.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Điểm rơi hiện tại: $dropoutPoint',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
          const SizedBox(height: AppSpacing.sp12),
          ...sortedKeys.map((key) {
            final value = cohortByLevel[key] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
              child: Text(
                '$key: ${(value * 100).round()}%',
                style: AppTypography.label.copyWith(
                  color: AppColors.slateMuted,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

Future<void> _openWeakAreaReview(
  BuildContext context,
  WidgetRef ref,
  String? weakestAreaType,
) async {
  if (weakestAreaType == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chưa đủ dữ liệu để đề xuất phiên ôn tập.')),
    );
    return;
  }

  List<ReviewItem> items = const [];
  if (weakestAreaType == 'kanji') {
    final due = await ref.read(dueKanjiCardsProvider.future);
    items = due.map(ReviewItem.fromKanji).toList();
  } else if (weakestAreaType == 'vocabulary' || weakestAreaType == 'vocab') {
    final due = await ref.read(dueVocabularyProvider.future);
    items = due.map((v) => ReviewItem.fromVocabulary(v)).toList();
  } else if (weakestAreaType == 'grammar') {
    final due = await ref.read(dueGrammarProvider.future);
    items = due.map(ReviewItem.fromGrammar).toList();
  }

  if (!context.mounted) return;
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không có thẻ đến hạn cho mục này.')),
    );
    return;
  }

  Navigator.push(context, AppRoutes.review(items));
}

class _WeakAreaInsightCard extends StatelessWidget {
  final String area;
  final String? areaType;
  final double successRate;
  final VoidCallback onPracticeNow;

  const _WeakAreaInsightCard({
    required this.area,
    required this.areaType,
    required this.successRate,
    required this.onPracticeNow,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (successRate * 100).round();
    final hasData = areaType != null;

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ưu tiên luyện tập',
            style: AppTypography.headingS.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            hasData
                ? 'Mảng cần ưu tiên hiện tại: $area (độ chính xác $percent%).'
                : 'Chưa có đủ dữ liệu ôn tập trong 30 ngày gần nhất để đề xuất.',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
          if (hasData) ...[
            const SizedBox(height: AppSpacing.sp12),
            Text(
              'Gợi ý: tăng tần suất ôn mục này trong 3-5 ngày tới để cải thiện tỉ lệ nhớ.',
              style: AppTypography.label.copyWith(color: AppColors.slateMuted),
            ),
            const SizedBox(height: AppSpacing.sp12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onPracticeNow,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Luyện ngay'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
