import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../providers/garden_provider.dart';
import '../providers/home_progress_provider.dart';
import '../providers/progress_models.dart';
import '../widgets/learning_card.dart';
import '../widgets/zen_garden_2d_widget.dart';
import '../widgets/global_search_delegate.dart';
import '../widgets/home/profile_avatar.dart';
import '../widgets/home/hero_header.dart';
import '../widgets/home/daily_progress_card.dart';
import '../widgets/home/quick_action_chips.dart';
import '../widgets/home/collapsed_title.dart';
import 'garden_screen.dart';

/// Callback type cho tab switching — truyền từ MainNavigation xuống HomePage
typedef TabSwitchCallback = void Function(int index);

/// Home Page — Trang chủ với Zen Garden Dashboard (Redesigned)
class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onSwitchTab;

  const HomePage({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);
    final progressAsync = ref.watch(homeProgressProvider);
    final authState = ref.watch(authStateProvider);

    // Lấy user info cho profile avatar
    final User? user = authState.valueOrNull;

    return progressAsync.when(
      data: (progress) => _buildContent(context, ref, garden, progress, user),
      loading: () => _buildContent(context, ref, garden, HomeProgress.empty, user),
      error: (e, _) => _buildContent(context, ref, garden, HomeProgress.empty, user),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    dynamic garden,
    HomeProgress progress,
    User? user,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── SliverAppBar + Profile Avatar + Search ──────────
        SliverAppBar(
          expandedHeight: AppSpacing.zenHeaderExpandedHeight,
          pinned: true,
          stretch: true,
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const CollapsedTitle(),
          actions: [
            // Search button
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
            // Profile avatar
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp12),
              child: ProfileAvatar(user: user),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            background: HeroHeader(
              progress: progress,
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
            child: DailyProgressCard(progress: progress),
          ),
        ),

        // ── 2D Zen Garden ───────────────────────────────────
        SliverToBoxAdapter(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GardenScreen()),
                );
              },
            ),
          ),
        ),

        // ── Quick Actions (Horizontal Chips) ────────────────
        SliverToBoxAdapter(
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
                  child: Text('Hành động nhanh', style: AppTypography.headingM),
                ),
                const SizedBox(height: AppSpacing.sp12),
                QuickActionChips(
                  ref: ref,
                  context: context,
                  onSwitchTab: onSwitchTab,
                ),
              ],
            ),
          ),
        ),

        // ── Section Title: Bắt đầu học ─────────────────────
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

        // ── 3 Learning Cards (Từ vựng, Ngữ pháp, Chữ Hán) ───────────
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
                subtitle: 'Tập viết và ghi nhớ Kanji',
                icon: Icons.translate_rounded,
                progress: progress.kanji.percentage,
                heroTag: 'kanji_card',
                accentColor: AppColors.mossGreen,
                onTap: () {
                  onSwitchTab?.call(3); // Switch to Chữ Hán tab
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
