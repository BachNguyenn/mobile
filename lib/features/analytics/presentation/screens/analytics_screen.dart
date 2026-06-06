import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../grammar/application/providers/grammar_library_provider.dart';
import '../../../kanji/application/providers/kanji_library_provider.dart';
import '../../../auth/application/providers/auth_provider.dart';
import '../../application/providers/analytics_provider.dart';
import '../../domain/entities/analytics_data.dart';
import '../widgets/analytics_stat_card.dart';
import '../widgets/analytics_heatmap.dart';
import '../widgets/analytics_jlpt_progress.dart';
import '../../../review/domain/entities/review_item.dart';
import '../../../vocabulary/application/providers/vocabulary_library_provider.dart';
import '../../../../presentation/navigation/app_routes.dart';
import '../../../../shared/widgets/app_page_background.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/section_header.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final user = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ học tập', style: AppTypography.headingM),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: analyticsAsync.when(
        data: (data) => AppPageBackground(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.sp24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileSummaryCard(
                  name: user?.displayName ?? 'Zen Learner',
                  email: user?.email ?? '',
                  photoUrl: user?.photoUrl,
                  data: data,
                ),
                const SizedBox(height: AppSpacing.sp24),
                const SectionHeader(
                  icon: Icons.insights_rounded,
                  title: 'Tổng quan',
                  subtitle: 'Nhịp học, ghi nhớ và hoàn thành trong một nơi.',
                  color: AppColors.zenBlue,
                ),
                const SizedBox(height: AppSpacing.sp12),
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
                const SectionHeader(
                  icon: Icons.calendar_month_rounded,
                  title: 'Mức độ hoạt động',
                  subtitle: 'Các ngày bạn có tương tác học tập gần đây.',
                  color: AppColors.mossGreen,
                ),
                const SizedBox(height: AppSpacing.sp16),
                AppCard(child: AnalyticsHeatmap(heatmapData: data.heatmapData)),
                const SizedBox(height: AppSpacing.sp32),
                const SectionHeader(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Tiến độ JLPT',
                  subtitle: 'Theo dõi mức độ bao phủ từng cấp độ.',
                  color: AppColors.sunGold,
                ),
                const SizedBox(height: AppSpacing.sp16),
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
        loading: () => const AppPageBackground(
          child: AppLoadingIndicator(color: AppColors.leafGreen),
        ),
        error: (err, stack) => AppPageBackground(
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Không tải được hồ sơ',
            message: 'Lỗi: $err',
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final AnalyticsData data;

  const _ProfileSummaryCard({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final success = (data.successRateLast30Days * 100).round();

    return AppCard(
      gradient: AppColors.brandLeafGradient,
      borderColor: AppColors.white.withValues(alpha: 0.14),
      shadowColor: AppColors.resolve(AppColors.zenBlue, context).withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.white.withValues(alpha: 0.18),
                backgroundImage: photoUrl == null
                    ? null
                    : NetworkImage(photoUrl!),
                child: photoUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '禅',
                        style: AppTypography.headingS.copyWith(
                          color: AppColors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sp16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingM.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          color: AppColors.white.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp20),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Đã học',
                  value: data.learned.toString(),
                ),
              ),
              Expanded(
                child: _HeroStat(
                  label: 'Ngày/30',
                  value: data.activeDaysLast30Days.toString(),
                ),
              ),
              Expanded(
                child: _HeroStat(label: 'Tỉ lệ nhớ', value: '$success%'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTypography.statNumber.copyWith(
            color: AppColors.white,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelS.copyWith(
            color: AppColors.white.withValues(alpha: 0.72),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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

    return AppCard(
      padding: AppSpacing.cardPadding,
      color: Theme.of(context).cardColor,
      borderColor: AppColors.resolve(AppColors.slateLight, context).withValues(alpha: 0.2),
      shadowColor: AppColors.resolve(AppColors.navyDark, context).withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tỉ lệ nhớ theo cấp độ',
            style: AppTypography.headingS.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Điểm rơi hiện tại: $dropoutPoint',
            style: AppTypography.bodyM.copyWith(color: AppColors.resolve(AppColors.slateGrey, context)),
          ),
          const SizedBox(height: AppSpacing.sp12),
          ...sortedKeys.map((key) {
            final value = cohortByLevel[key] ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
              child: Text(
                '$key: ${(value * 100).round()}%',
                style: AppTypography.label.copyWith(
                  color: AppColors.resolve(AppColors.slateMuted, context),
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

    return AppCard(
      padding: AppSpacing.cardPadding,
      color: Theme.of(context).cardColor,
      borderColor: AppColors.resolve(AppColors.slateLight, context).withValues(alpha: 0.2),
      shadowColor: AppColors.resolve(AppColors.navyDark, context).withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ưu tiên luyện tập',
            style: AppTypography.headingS.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            hasData
                ? 'Mảng cần ưu tiên hiện tại: $area (độ chính xác $percent%).'
                : 'Chưa có đủ dữ liệu ôn tập trong 30 ngày gần nhất để đề xuất.',
            style: AppTypography.bodyM.copyWith(color: AppColors.resolve(AppColors.slateGrey, context)),
          ),
          if (hasData) ...[
            const SizedBox(height: AppSpacing.sp12),
            Text(
              'Gợi ý: tăng tần suất ôn mục này trong 3-5 ngày tới để cải thiện tỉ lệ nhớ.',
              style: AppTypography.label.copyWith(color: AppColors.resolve(AppColors.slateMuted, context)),
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
