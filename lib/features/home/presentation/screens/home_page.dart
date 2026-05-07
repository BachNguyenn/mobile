import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/garden/presentation/providers/garden_mission_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/widgets/collapsed_title.dart';
import 'package:mobile/features/home/presentation/widgets/hero_header.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/features/home/presentation/widgets/quick_action_chips.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/presentation/widgets/global_search_delegate.dart';
import 'package:mobile/presentation/widgets/learning_card.dart';
import 'package:mobile/presentation/widgets/zen_garden_2d_widget.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerStatefulWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);
    final gardenMissions = ref.watch(gardenMissionProvider);
    final progressAsync = ref.watch(homeProgressProvider);
    final authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;

    return progressAsync.when(
      data: (progress) => _buildContent(context, ref, garden, gardenMissions, progress, user),
      loading: () =>
          _buildContent(context, ref, garden, gardenMissions, HomeProgress.empty, user),
      error: (e, _) =>
          _buildContent(context, ref, garden, gardenMissions, HomeProgress.empty, user),
    );
  }

  Widget _staggeredItem({required int index, required Widget child}) {
    final delay = index * 0.12;
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final progress = ((_staggerController.value - delay) / 0.4).clamp(
          0.0,
          1.0,
        );
        final curve = Curves.easeOutCubic.transform(progress);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - curve)),
          child: Opacity(opacity: curve, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ZenGarden garden,
    AsyncValue<GardenMissionSummary> gardenMissions,
    HomeProgress progress,
    User? user,
  ) {
    return AppPageBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.cream.withValues(alpha: 0.94),
            surfaceTintColor: Colors.transparent,
            title: const CollapsedTitle(),
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: GlobalSearchDelegate(ref),
                  );
                },
                icon: const Icon(Icons.search_rounded, size: 22),
                color: AppColors.slateGrey,
                tooltip: 'Tìm kiếm',
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sp12),
                child: ProfileAvatar(user: user),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.zenHeaderExpandedHeight,
              child: HeroHeader(
                progress: progress,
                streak: progress.streak,
                overdueCount: progress.overdueCount,
                todayReviewed: progress.todayReviewed,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _staggeredItem(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp24,
                  AppSpacing.sp20,
                  AppSpacing.sp24,
                  AppSpacing.sp8,
                ),
                child: _HomeOverviewPanel(progress: progress),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _staggeredItem(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp24,
                  AppSpacing.sp16,
                  AppSpacing.sp24,
                  AppSpacing.sp8,
                ),
                child: ZenGarden2DWidget(
                garden: garden,
                streak: progress.streak,
                missionHint: gardenMissions.valueOrNull?.homeHint,
                onTap: () {
                    Navigator.push(context, AppRoutes.garden());
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _staggeredItem(
              index: 2,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sp16,
                  bottom: AppSpacing.sp8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppSpacing.paddingH24,
                      child: _HomeSectionHeader(
                        Icons.flash_on_rounded,
                        title: 'Hành động nhanh',
                        color: AppColors.sunGold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    QuickActionChips(
                      ref: ref,
                      context: context,
                      onOpenLearningCategory: widget.onOpenLearningCategory,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _staggeredItem(index: 3, child: const _ZenDivider()),
          ),
          SliverToBoxAdapter(
            child: _staggeredItem(
              index: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp24,
                  AppSpacing.sp8,
                  AppSpacing.sp24,
                  AppSpacing.sp12,
                ),
                child: _HomeSectionHeader(
                  Icons.auto_stories_rounded,
                  title: 'Bắt đầu học',
                  color: AppColors.mossGreen,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.paddingH24,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _staggeredItem(
                  index: 5,
                  child: LearningCard(
                    title: 'Từ vựng',
                    subtitle: 'Mở rộng vốn từ và nhận mặt cụm quen dùng',
                    badge: 'Theo chủ đề',
                    metricLabel: 'Đã học',
                    metricValue:
                        '${progress.vocabulary.learned}/${progress.vocabulary.total}',
                    highlights: const ['Từ mới', 'Ngữ cảnh'],
                    icon: Icons.menu_book_rounded,
                    progress: progress.vocabulary.percentage,
                    heroTag: 'vocabulary_card',
                    accentColor: AppColors.waterBlue,
                    onTap: () {
                      widget.onOpenTab?.call(2);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sp16),
                _staggeredItem(
                  index: 6,
                  child: LearningCard(
                    title: 'Ngữ pháp',
                    subtitle: 'Luyện mẫu câu và cách dùng từ N5 đến N1',
                    badge: 'Mẫu câu',
                    metricLabel: 'Tiến độ',
                    metricValue:
                        '${(progress.grammar.percentage * 100).round()}% hoàn thành',
                    highlights: const ['Cấu trúc', 'Ví dụ'],
                    icon: Icons.edit_note_rounded,
                    progress: progress.grammar.percentage,
                    heroTag: 'grammar_card',
                    accentColor: AppColors.sunGold,
                    onTap: () {
                      widget.onOpenTab?.call(3);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sp16),
                _staggeredItem(
                  index: 7,
                  child: LearningCard(
                    title: 'Chữ Hán',
                    subtitle: 'Tập viết, nhớ nghĩa và nối âm đọc Kanji',
                    badge: 'Nét viết',
                    metricLabel: 'Đã nhớ',
                    metricValue:
                        '${progress.kanji.learned}/${progress.kanji.total} ký tự',
                    highlights: const ['On/Kun', 'Viết tay'],
                    icon: Icons.translate_rounded,
                    progress: progress.kanji.percentage,
                    heroTag: 'kanji_card',
                    accentColor: AppColors.mossGreen,
                    onTap: () {
                      widget.onOpenTab?.call(4);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sp48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeOverviewPanel extends StatelessWidget {
  final HomeProgress progress;

  const _HomeOverviewPanel({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp20,
              AppSpacing.sp20,
              AppSpacing.sp20,
              AppSpacing.sp12,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.mossGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mossGreen.withValues(alpha: 0.20),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tiến độ hôm nay',
                        style: AppTypography.headingS.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),
                      Text(
                        '${progress.todayReviewed} thẻ đã ôn',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress.overallPercentage * 100).round()}%',
                  style: AppTypography.statNumber.copyWith(
                    color: AppColors.mossDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
              child: LinearProgressIndicator(
                value: progress.overallPercentage.clamp(0.0, 1.0).toDouble(),
                minHeight: 8,
                backgroundColor: AppColors.creamDark,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.mossGreen,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp16),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp12,
              0,
              AppSpacing.sp12,
              AppSpacing.sp12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _OverviewMetric(
                    label: 'Từ vựng',
                    value:
                        '${progress.vocabulary.learned}/${progress.vocabulary.total}',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.waterBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp8),
                Expanded(
                  child: _OverviewMetric(
                    label: 'Ngữ pháp',
                    value: '${(progress.grammar.percentage * 100).round()}%',
                    icon: Icons.edit_note_rounded,
                    color: AppColors.sunGold,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp8),
                Expanded(
                  child: _OverviewMetric(
                    label: 'Chữ Hán',
                    value: '${progress.kanji.learned}/${progress.kanji.total}',
                    icon: Icons.translate_rounded,
                    color: AppColors.mossGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            value,
            style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTypography.labelS,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _HomeSectionHeader(
    this.icon, {
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: AppSpacing.sp8),
        Text(title, style: AppTypography.headingM),
      ],
    );
  }
}

class _ZenDivider extends StatelessWidget {
  const _ZenDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp48,
        vertical: AppSpacing.sp16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp12),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.slateMuted.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
