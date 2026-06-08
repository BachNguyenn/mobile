import 'package:flutter/material.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class BentoDashboard extends StatelessWidget {
  final HomeProgress progress;
  final List<WeaknessReviewItem> weakItems;
  final VoidCallback onOpenWeakness;
  final VoidCallback onOpenGarden;

  const BentoDashboard({
    super.key,
    required this.progress,
    required this.weakItems,
    required this.onOpenWeakness,
    required this.onOpenGarden,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBlue = AppColors.resolve(AppColors.zenBlue, context);
    final resolvedGold = AppColors.resolve(AppColors.sunGold, context);
    final resolvedGreen = AppColors.resolve(AppColors.leafGreen, context);
    final resolvedTerracotta = AppColors.resolve(AppColors.terracotta, context);
    
    final weakKanji = _firstWeak(ReviewItemType.kanji);
    final weakGrammar = _firstWeak(ReviewItemType.grammar);
    final jlptPercent = (progress.overallPercentage * 100).round();
    final todayHint = _getTodayHint();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Dashboard cá nhân',
              style: AppTypography.headingS.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          todayHint,
          style: AppTypography.caption.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: AppSpacing.sp12),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _BentoTile(
                color: resolvedBlue,
                onTap: onOpenWeakness,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist_rtl_rounded, color: resolvedBlue, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'Thẻ ôn tập',
                          style: AppTypography.labelS.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${progress.overdueCount}',
                                style: AppTypography.headingM.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: resolvedBlue,
                                ),
                              ),
                              Text(
                                'Đến hạn',
                                style: AppTypography.labelS.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: resolvedBlue.withValues(alpha: 0.1)),
                        const SizedBox(width: AppSpacing.sp12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${progress.dueSoonCount}',
                                style: AppTypography.headingM.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.resolve(AppColors.waterBlue, context),
                                ),
                              ),
                              Text(
                                '24h tới',
                                style: AppTypography.labelS.copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sp8),
            Expanded(
              flex: 2,
              child: _BentoTile(
                color: resolvedTerracotta,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: resolvedTerracotta, size: 20),
                        const SizedBox(width: AppSpacing.sp4),
                        Text(
                          'Streak',
                          style: AppTypography.labelS.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Text(
                      '${progress.streak} ngày',
                      style: AppTypography.headingS.copyWith(
                        fontWeight: FontWeight.w900,
                        color: resolvedTerracotta,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Đều đặn mỗi ngày!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelS.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _BentoTile(
                color: resolvedGreen,
                onTap: onOpenGarden,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.yard_rounded, color: resolvedGreen, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            progress.gardenPlantCount == 0 ? 'Vườn mới bắt đầu' : '${progress.gardenPlantCount} cây đang lớn',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelS.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 12, color: AppColors.waterBlue),
                            const SizedBox(width: 2),
                            Text(
                              'Nước ${progress.gardenWater}',
                              style: AppTypography.labelS.copyWith(fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.wb_sunny_rounded, size: 12, color: AppColors.sunGold),
                            const SizedBox(width: 2),
                            Text(
                              'Nắng ${progress.gardenSunlight}',
                              style: AppTypography.labelS.copyWith(fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.sakura),
                            const SizedBox(width: 2),
                            Text(
                              '${progress.gardenExp} XP · $jlptPercent%',
                              style: AppTypography.labelS.copyWith(fontWeight: FontWeight.w900, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (weakKanji != null || weakGrammar != null) ...[
          const SizedBox(height: AppSpacing.sp8),
          _BentoTile(
            color: resolvedGold,
            onTap: onOpenWeakness,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: resolvedGold, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Cần chú ý',
                      style: AppTypography.labelS.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp8),
                if (weakKanji != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kanji hay sai: ${_displayText(weakKanji)}',
                          style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${weakKanji.misses} lần sai',
                          style: AppTypography.labelS.copyWith(color: resolvedTerracotta, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                if (weakGrammar != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Grammar hay quên: ${_displayText(weakGrammar)}',
                        style: AppTypography.bodyS.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${weakGrammar.misses} lần sai',
                        style: AppTypography.labelS.copyWith(color: resolvedTerracotta, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _getTodayHint() {
    if (progress.overdueCount > 0) {
      return 'Ưu tiên ôn ${progress.overdueCount} thẻ đang chờ.';
    }
    if (progress.dueSoonCount > 0) {
      return '${progress.dueSoonCount} thẻ sẽ đến hạn trong 24 giờ tới.';
    }
    return 'Không có nợ ôn, có thể học bài mới hoặc luyện câu.';
  }

  WeaknessReviewItem? _firstWeak(ReviewItemType type) {
    for (final item in weakItems) {
      if (item.type == type) return item;
    }
    return null;
  }

  String _displayText(WeaknessReviewItem item) {
    final review = item.reviewItem;
    switch (item.type) {
      case ReviewItemType.kanji:
        return review.kanji?.kanji ?? review.answer;
      case ReviewItemType.grammar:
        return review.grammar?.title ?? review.answer;
      case ReviewItemType.vocabulary:
        return review.vocabulary?.word ?? review.prompt;
      case ReviewItemType.sentence:
        return review.sentence?.text ?? review.prompt;
    }
  }
}

class _BentoTile extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback? onTap;

  const _BentoTile({
    required this.color,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp16,
        vertical: AppSpacing.sp12,
      ),
      borderColor: color.withValues(alpha: isDark ? 0.25 : 0.14),
      shadowColor: color.withValues(alpha: 0.04),
      child: child,
    );
  }
}
