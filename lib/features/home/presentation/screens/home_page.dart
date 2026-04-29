import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/widgets/collapsed_title.dart';
import 'package:mobile/features/home/presentation/widgets/daily_progress_card.dart';
import 'package:mobile/features/home/presentation/widgets/hero_header.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/features/home/presentation/widgets/quick_action_chips.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/presentation/widgets/global_search_delegate.dart';
import 'package:mobile/presentation/widgets/learning_card.dart';
import 'package:mobile/presentation/widgets/zen_garden_2d_widget.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garden = ref.watch(gardenProvider);
    final progressAsync = ref.watch(homeProgressProvider);
    final authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;

    return progressAsync.when(
      data: (progress) => _buildContent(context, ref, garden, progress, user),
      loading: () =>
          _buildContent(context, ref, garden, HomeProgress.empty, user),
      error: (e, _) =>
          _buildContent(context, ref, garden, HomeProgress.empty, user),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ZenGarden garden,
    HomeProgress progress,
    User? user,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.cream,
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
                Navigator.push(context, AppRoutes.garden());
              },
            ),
          ),
        ),
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
                  onOpenLearningCategory: onOpenLearningCategory,
                ),
              ],
            ),
          ),
        ),
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
        SliverPadding(
          padding: AppSpacing.paddingH24,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              LearningCard(
                title: 'Từ vựng',
                subtitle: 'Học từ mới theo chủ đề',
                icon: Icons.menu_book_rounded,
                progress: progress.vocabulary.percentage,
                heroTag: 'vocabulary_card',
                accentColor: AppColors.waterBlue,
                onTap: () {
                  onOpenTab?.call(2);
                },
              ),
              const SizedBox(height: AppSpacing.sp16),
              LearningCard(
                title: 'Ngữ pháp',
                subtitle: 'Cấu trúc câu từ N5 đến N1',
                icon: Icons.edit_note_rounded,
                progress: progress.grammar.percentage,
                heroTag: 'grammar_card',
                accentColor: AppColors.sunGold,
                onTap: () {
                  onOpenTab?.call(3);
                },
              ),
              const SizedBox(height: AppSpacing.sp16),
              LearningCard(
                title: 'Chữ Hán',
                subtitle: 'Tập viết và ghi nhớ Kanji',
                icon: Icons.translate_rounded,
                progress: progress.kanji.percentage,
                heroTag: 'kanji_card',
                accentColor: AppColors.mossGreen,
                onTap: () {
                  onOpenTab?.call(4);
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
