import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/garden_provider.dart';
import '../providers/home_progress_provider.dart';
import '../providers/kanji_library_provider.dart';
import '../widgets/learning_card.dart';
import '../widgets/zen_garden_header.dart';
import 'analytics_screen.dart';
import 'garden_screen.dart';
import 'learning_path_screen.dart';
import 'review_screen.dart';
import 'grammar_analysis_screen.dart';
import '../widgets/global_search_delegate.dart';

/// Callback type cho tab switching — truyền từ MainNavigation xuống HomePage
typedef TabSwitchCallback = void Function(int index);

/// Home Page — Trang chủ với Zen Garden Dashboard
///
/// Cấu trúc:
/// - SliverAppBar với Zen Garden Header (dashboard cảm xúc)
/// - Daily progress summary
/// - 3 Learning Cards lớn (Từ vựng, Ngữ pháp, Chữ Hán)
///
/// Sử dụng SliverAppBar để Header thu nhỏ khi scroll.
/// Hero animation khi chuyển từ card sang detail screen.
class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onSwitchTab;

  const HomePage({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);
    final progressAsync = ref.watch(homeProgressProvider);

    return progressAsync.when(
      data: (progress) => _buildContent(context, ref, garden, progress),
      loading: () => _buildContent(context, ref, garden, HomeProgress.empty),
      error: (e, _) => _buildContent(context, ref, garden, HomeProgress.empty),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic garden,
    HomeProgress progress,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SliverAppBar + Zen Garden Header ────────────────
        SliverAppBar(
          expandedHeight: AppSpacing.zenHeaderExpandedHeight,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const _CollapsedTitle(),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: ZenGardenHeader(
              garden: garden,
              streak: progress.streak,
              overdueCount: progress.overdueCount,
              todayReviewed: progress.todayReviewed,
            ),
          ),
        ),

        // ── Daily Progress Summary ──────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp24,
              AppSpacing.sp20,
              AppSpacing.sp24,
              AppSpacing.sp8,
            ),
            child: _DailyProgressCard(progress: progress),
          ),
        ),

        // ── Section Title ───────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp24,
              AppSpacing.sp16,
              AppSpacing.sp24,
              AppSpacing.sp12,
            ),
            child: Text('Bắt đầu học', style: AppTypography.headingM),
          ),
        ),

        // ── 3 Learning Cards ────────────────────────────────
        SliverPadding(
          padding: AppSpacing.paddingH24,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Card 1: Từ vựng
              LearningCard(
                title: 'Từ vựng',
                subtitle: 'Học từ mới theo chủ đề',
                icon: Icons.menu_book_rounded,
                progress: progress.vocabulary.percentage,
                heroTag: 'vocabulary_card',
                accentColor: AppColors.waterBlue,
                onTap: () {
                  onSwitchTab?.call(1); // Switch to Từ vựng tab
                },
              ),

              const SizedBox(height: AppSpacing.sp16),

              // Card 2: Ngữ pháp
              LearningCard(
                title: 'Ngữ pháp',
                subtitle: 'Cấu trúc câu từ N5 đến N1',
                icon: Icons.edit_note_rounded,
                progress: progress.grammar.percentage,
                heroTag: 'grammar_card',
                accentColor: AppColors.sunGold,
                onTap: () {
                  onSwitchTab?.call(2); // Switch to Ngữ pháp tab
                },
              ),

              const SizedBox(height: AppSpacing.sp16),

              // Card 3: Chữ Hán
              LearningCard(
                title: 'Chữ Hán',
                subtitle: '${progress.kanji.learned}/${progress.kanji.total} đã học',
                icon: Icons.translate_rounded,
                progress: progress.kanji.percentage,
                heroTag: 'kanji_card',
                accentColor: AppColors.mossGreen,
                onTap: () {
                  onSwitchTab?.call(3); // Switch to Chữ Hán tab
                },
              ),

              const SizedBox(height: AppSpacing.sp24),

              // ── Quick Actions (4 nút) ──────────────────────
              _QuickActionGrid(
                onReviewTap: () {
                  // Ôn tập thẻ quá hạn từ real data
                  ref.read(dueKanjiCardsProvider.future).then((dueCards) {
                    if (!context.mounted) return;
                    if (dueCards.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReviewScreen(cards: dueCards),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không có thẻ nào cần ôn tập!')),
                      );
                    }
                  });
                },
                onNewLessonTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LearningPathScreen(),
                    ),
                  );
                },
                onGardenTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GardenScreen(),
                    ),
                  );
                },
                onAnalyticsTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnalyticsScreen(),
                    ),
                  );
                },
                onAITap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GrammarAnalysisScreen(),
                    ),
                  );
                },
                onSearchTap: () {
                  showSearch(context: context, delegate: GlobalSearchDelegate(ref));
                },
              ),

              const SizedBox(height: AppSpacing.sp48),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Title hiển thị khi AppBar thu nhỏ (collapsed)
class _CollapsedTitle extends StatelessWidget {
  const _CollapsedTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Zen Japanese',
      style: AppTypography.headingS.copyWith(
        color: AppColors.ink,
      ),
    );
  }
}

/// Card tóm tắt tiến độ ngày
class _DailyProgressCard extends StatelessWidget {
  final HomeProgress progress;

  const _DailyProgressCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(
          color: AppColors.slateLight.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiến độ hôm nay', style: AppTypography.bodyMBold),
              Text(
                '${progress.todayReviewed} thẻ đã ôn',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.progressBarHeight / 2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.overallPercentage),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value.clamp(0.0, 1.0),
                  minHeight: AppSpacing.progressBarHeight,
                  backgroundColor: AppColors.creamDark,
                  valueColor: const AlwaysStoppedAnimation(AppColors.mossGreen),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick action grid (6 nút: Ôn tập, Bài mới, Vườn Zen, Thống kê, AI, Tra cứu)
class _QuickActionGrid extends StatelessWidget {
  final VoidCallback onReviewTap;
  final VoidCallback onNewLessonTap;
  final VoidCallback onGardenTap;
  final VoidCallback onAnalyticsTap;
  final VoidCallback onAITap;
  final VoidCallback onSearchTap;

  const _QuickActionGrid({
    required this.onReviewTap,
    required this.onNewLessonTap,
    required this.onGardenTap,
    required this.onAnalyticsTap,
    required this.onAITap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hành động nhanh', style: AppTypography.headingM),
        const SizedBox(height: AppSpacing.sp16),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.auto_stories_rounded,
                label: 'Ôn tập',
                color: AppColors.terracotta,
                onTap: onReviewTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sp12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Bài mới',
                color: AppColors.mossGreen,
                onTap: onNewLessonTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.park_rounded,
                label: 'Vườn Zen',
                color: AppColors.waterBlue,
                onTap: onGardenTap,
              ),
            ),
            const SizedBox(width: AppSpacing.sp12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart_rounded,
                label: 'Thống kê',
                color: AppColors.sunGold,
                onTap: onAnalyticsTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.psychology_rounded,
                label: 'Phân tích AI',
                color: Colors.purple,
                onTap: onAITap,
              ),
            ),
            const SizedBox(width: AppSpacing.sp12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.search_rounded,
                label: 'Tra cứu',
                color: AppColors.slateGrey,
                onTap: onSearchTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sp20,
          horizontal: AppSpacing.sp16,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: AppSpacing.sp8),
            Text(
              label,
              style: AppTypography.bodyMBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
