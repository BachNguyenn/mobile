import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/garden/application/providers/garden_mission_provider.dart';
import 'package:mobile/features/garden/presentation/models/garden_mission_style.dart';
import 'package:mobile/features/home/application/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/application/providers/home_progress_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/navigation/daily_study_navigation.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/features/home/presentation/widgets/quick_action_chips.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/weakness/application/providers/weakness_provider.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(homeProgressProvider).value;
    final dailyPlan = ref.watch(dailyStudyPlanProvider);
    final missions = ref.watch(gardenMissionProvider);
    final weakItems = ref.watch(weakItemsProvider).value ?? const [];
    final user = ref.watch(authStateProvider).value;
    final data = progress ?? HomeProgress.empty;

    return Scaffold(
      body: AppPageBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp20,
                  AppSpacing.sp12,
                  AppSpacing.sp20,
                  116,
                ),
                sliver: SliverList.list(
                  children: [
                    _TopBar(user: user),
                    const SizedBox(height: AppSpacing.sp20),
                    _DailyStudyCard(
                      plan: dailyPlan,
                      progress: data,
                      onTap: (plan) => openDailyStudyPlan(
                        context,
                        ref,
                        plan,
                        onOpenLearningCategory: onOpenLearningCategory,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    _BentoDashboard(
                      progress: data,
                      weakItems: weakItems,
                      onOpenWeakness: () =>
                          Navigator.push(context, AppRoutes.weakness()),
                      onOpenGarden: () =>
                          Navigator.push(context, AppRoutes.garden()),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    _QuickActionsBar(
                      onOpenWeakness: () =>
                          Navigator.push(context, AppRoutes.weakness()),
                      onOpenPlacement: () =>
                          Navigator.push(context, AppRoutes.placementTest()),
                      onOpenSentencePractice: () =>
                          Navigator.push(context, AppRoutes.sentencePractice()),
                      onOpenGarden: () =>
                          Navigator.push(context, AppRoutes.garden()),
                      onOpenAnalytics: () =>
                          Navigator.push(context, AppRoutes.analytics()),
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    _MissionCard(
                      missions: missions,
                      onTap: () => Navigator.push(context, AppRoutes.garden()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final AuthUser? user;

  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.resolve(AppColors.navySoft, context),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_logo_clean.png',
            cacheWidth: 96,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(width: AppSpacing.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingS.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '日本語を少しずつ',
                style: AppTypography.label.copyWith(
                  color: AppColors.resolve(AppColors.leafDark, context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sp8),
        SizedBox.square(
          dimension: 44,
          child: IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () => Navigator.push(context, AppRoutes.dictionary()),
            icon: const Icon(Icons.search_rounded),
            color: AppColors.resolve(AppColors.zenBlue, context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: AppSpacing.sp4),
        ProfileAvatar(user: user),
        const SizedBox(width: 2),
      ],
    );
  }

  String _displayName(AuthUser? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'bạn';
  }
}

class _DailyStudyCard extends StatelessWidget {
  final AsyncValue<DailyStudyPlan> plan;
  final HomeProgress progress;
  final ValueChanged<DailyStudyPlan> onTap;

  const _DailyStudyCard({
    required this.plan,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress.overallPercentage * 100).round();
    final currentPlan = plan.value;
    final title = currentPlan?.title ?? 'Đang chọn phiên học';
    final subtitle =
        currentPlan?.subtitle ?? 'Đang chọn phiên học phù hợp cho bạn.';
    final compactReason =
        currentPlan?.reason.replaceFirst(' đến hạn', '') ??
        'Dựa trên tiến độ hiện tại';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);
    return AppCard(
      onTap: currentPlan == null ? null : () => onTap(currentPlan),
      color: isDark ? null : resolvedZenBlue,
      borderColor: isDark
          ? const Color(0xFF353F6C).withValues(alpha: 0.4)
          : resolvedZenBlue,
      gradient: isDark
          ? const LinearGradient(
              colors: [Color(0xFF1F2544), Color(0xFF151A30)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      shadowColor: isDark
          ? Colors.transparent
          : resolvedZenBlue.withValues(alpha: 0.16),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp16,
        AppSpacing.sp12,
        AppSpacing.sp16,
        AppSpacing.sp12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp8,
                  vertical: AppSpacing.sp4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.leafLight,
                    ),
                    const SizedBox(width: AppSpacing.sp4),
                    Text(
                      'Hôm nay học gì?',
                      style: AppTypography.label.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (currentPlan != null)
                _DailyStudyPill(
                  icon: Icons.flag_rounded,
                  label: 'N${currentPlan.level}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingM.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.white.withValues(alpha: 0.74),
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: [
              _DailyStudyPill(
                icon: Icons.tips_and_updates_rounded,
                label: compactReason,
              ),
              if (currentPlan != null && currentPlan.itemCount > 0)
                _DailyStudyPill(
                  icon: Icons.format_list_numbered_rounded,
                  label: '${currentPlan.itemCount} mục',
                ),
              _DailyStudyPill(icon: Icons.insights_rounded, label: '$percent%'),
              _DailyStudyPill(
                icon: Icons.local_fire_department_rounded,
                label: '${progress.streak} ngày',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: progress.overallPercentage.clamp(0.0, 1.0).toDouble(),
              minHeight: 6,
              backgroundColor: AppColors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.leafLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Row(
            children: [
              Text(
                currentPlan == null ? 'Đang chuẩn bị' : 'Bắt đầu ngay',
                style: AppTypography.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white.withValues(
                  alpha: currentPlan == null ? 0.5 : 1,
                ),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyStudyPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DailyStudyPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.white.withValues(alpha: 0.82)),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelS.copyWith(
              color: AppColors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoDashboard extends StatelessWidget {
  final HomeProgress progress;
  final List<WeaknessReviewItem> weakItems;
  final VoidCallback onOpenWeakness;
  final VoidCallback onOpenGarden;

  const _BentoDashboard({
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

class _QuickActionsBar extends StatelessWidget {
  final VoidCallback onOpenWeakness;
  final VoidCallback onOpenPlacement;
  final VoidCallback onOpenSentencePractice;
  final VoidCallback onOpenGarden;
  final VoidCallback onOpenAnalytics;

  const _QuickActionsBar({
    required this.onOpenWeakness,
    required this.onOpenPlacement,
    required this.onOpenSentencePractice,
    required this.onOpenGarden,
    required this.onOpenAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lối tắt',
          style: AppTypography.headingS.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.fact_check_rounded,
                label: 'Test đầu vào',
                onTap: onOpenPlacement,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.record_voice_over_rounded,
                label: 'Luyện câu',
                onTap: onOpenSentencePractice,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.yard_rounded,
                label: 'Vườn',
                onTap: onOpenGarden,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.psychology_alt_rounded,
                label: 'Điểm yếu',
                onTap: onOpenWeakness,
              ),
              const SizedBox(width: AppSpacing.sp8),
              _ActionChip(
                icon: Icons.insights_rounded,
                label: 'Hồ sơ',
                onTap: onOpenAnalytics,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBlue = AppColors.resolve(AppColors.zenBlue, context);
    return Material(
      color: resolvedBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: resolvedBlue),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: resolvedBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;
  final VoidCallback onTap;

  const _MissionCard({required this.missions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return missions.when(
      data: (summary) {
        final resolvedLeafGreen = AppColors.resolve(
          AppColors.leafGreen,
          context,
        );
        return AppCard(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp12,
            AppSpacing.sp16,
            AppSpacing.sp12,
          ),
          borderColor: resolvedLeafGreen.withValues(alpha: 0.14),
          shadowColor: resolvedLeafGreen.withValues(alpha: 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nhiệm vụ hôm nay',
                    style: AppTypography.headingS.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${summary.completedCount}/${summary.missions.length}',
                    style: AppTypography.label.copyWith(
                      color: resolvedLeafGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              ...summary.missions.map((mission) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                  child: _MissionRow(mission: mission),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const AppCard(child: SizedBox(height: 84)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final GardenMission mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(mission.color, context);
    return Row(
      children: [
        Icon(mission.icon, color: resolvedColor, size: 21),
        const SizedBox(width: AppSpacing.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Text(
                    '${mission.current}/${mission.target}',
                    style: AppTypography.label.copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: mission.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.resolve(
                    AppColors.creamDark,
                    context,
                  ),
                  valueColor: AlwaysStoppedAnimation<Color>(resolvedColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
