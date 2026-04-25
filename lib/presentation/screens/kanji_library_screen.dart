import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';
import '../providers/progress_models.dart';
import '../widgets/kanji/kanji_progress_card.dart';
import '../widgets/kanji/kanji_action_button.dart';
import '../widgets/kanji/kanji_grid_item.dart';
import '../widgets/kanji/kanji_jlpt_filter_dialog.dart';
import 'review_screen.dart';
import 'learning_path_screen.dart';

/// Thư viện Kanji — redesigned với Kanji-specific features
class KanjiLibraryScreen extends ConsumerWidget {
  const KanjiLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(kanjiSearchResultsProvider);
    final kanjiProgressAsync = ref.watch(kanjiProgressProvider);
    final dueCardsAsync = ref.watch(dueKanjiCardsProvider);
    final totalDueCountAsync = ref.watch(totalDueCountProvider);
    final selectedLevel = ref.watch(kanjiLevelFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.mossGreen,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'kanji_card',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Thư viện Chữ Hán',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.mossGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: AppColors.white),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => const KanjiJlptFilterDialog(),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp8,
              ),
              child: kanjiProgressAsync.when(
                data: (progress) => KanjiProgressCard(
                  progress: progress,
                  dueCount: totalDueCountAsync.valueOrNull ?? 0,
                ),
                loading: () => const KanjiProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                ),
                error: (e, _) => const KanjiProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                ),
              ),
            ),
          ),

          // ── Review Level Selector ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp8),
              child: _ReviewLevelSelector(),
            ),
          ),

          // ── Action Buttons (Ôn tập + Bài mới) ──────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp16,
                vertical: AppSpacing.sp8,
              ),
              child: Row(
                children: [
                  // Ôn tập button
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.auto_stories_rounded,
                      label: 'Ôn tập',
                      sublabel: totalDueCountAsync.when(
                        data: (totalDue) {
                          if (totalDue == 0) return 'Đã hoàn thành';
                          final cards = dueCardsAsync.valueOrNull ?? [];
                          return 'Học ${cards.length}/$totalDue thẻ';
                        },
                        loading: () => 'Đang tải...',
                        error: (e, _) => 'Lỗi',
                      ),
                      color: AppColors.terracotta,
                      onTap: () {
                        final dueCards = dueCardsAsync.value;
                        if (dueCards != null && dueCards.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewScreen(cards: dueCards),
                            ),
                          );
                        } else if (dueCards != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không có thẻ nào cần ôn tập!'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp12),
                  // Bài mới button
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Bài mới',
                      sublabel: 'Lộ trình học',
                      color: AppColors.mossGreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningPathScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp8,
                AppSpacing.sp16,
                AppSpacing.sp8,
              ),
              child: TextField(
                onChanged: (value) =>
                    ref.read(kanjiSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo Hán tự, nghĩa hoặc cách đọc...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.mossGreen,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide(
                      color: AppColors.slateLight.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: const BorderSide(
                      color: AppColors.mossGreen,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Section Title ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp8,
                AppSpacing.sp16,
                AppSpacing.sp4,
              ),
              child: Text(
                selectedLevel == null ? 'Tất cả chữ Hán' : 'Chữ Hán N$selectedLevel',
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.slateGrey,
                ),
              ),
            ),
          ),

          // ── Kanji Grid ──────────────────────────────────────
          searchResults.when(
            data: (kanjis) {
              if (kanjis.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: AppColors.slateLight,
                        ),
                        const SizedBox(height: AppSpacing.sp12),
                        Text(
                          'Không tìm thấy Chữ Hán nào.',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp16,
                ),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sp12,
                    crossAxisSpacing: AppSpacing.sp12,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return KanjiGridItem(kanji: kanjis[index]);
                    },
                    childCount: kanjis.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child:
                    CircularProgressIndicator(color: AppColors.mossGreen),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Lỗi: $err', style: AppTypography.bodyM),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.sp48),
          ),
        ],
      ),
    );
  }
}

class _ReviewLevelSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(kanjiLevelFilterProvider);
    final levels = [null, 5, 4, 3, 2, 1];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = currentFilter == level;
          final label = level == null ? 'Tất cả' : 'N$level';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                ref.read(kanjiLevelFilterProvider.notifier).state =
                    selected ? level : null;
              },
              selectedColor: AppColors.mossGreen.withValues(alpha: 0.2),
              labelStyle: AppTypography.label.copyWith(
                color: isSelected ? AppColors.mossGreen : AppColors.slateGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateLight.withValues(alpha: 0.3),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
