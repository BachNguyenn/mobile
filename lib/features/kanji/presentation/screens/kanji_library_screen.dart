import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import '../../../../core/models/progress_models.dart';
import '../providers/kanji_library_provider.dart';
import '../../../../shared/widgets/progress_card.dart';
import '../../../../shared/widgets/action_button.dart';
import '../widgets/kanji_library_app_bar.dart';
import '../widgets/kanji_library_search_bar.dart';
import '../widgets/kanji_level_selector.dart';
import '../widgets/kanji_grid_view.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';

class KanjiLibraryScreen extends ConsumerWidget {
  final ValueChanged<LearningCategory>? onOpenLearningCategory;

  const KanjiLibraryScreen({super.key, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kanjiProgressAsync = ref.watch(kanjiProgressProvider);
    final dueCardsAsync = ref.watch(dueKanjiCardsProvider);
    final totalDueCountAsync = ref.watch(totalDueCountProvider);
    final selectedLevel = ref.watch(kanjiLevelFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const KanjiLibraryAppBar(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp8,
              ),
              child: kanjiProgressAsync.when(
                data: (progress) => LibraryProgressCard(
                  progress: progress,
                  dueCount: totalDueCountAsync.valueOrNull ?? 0,
                  title: 'Chữ Hán',
                  icon: Icons.translate_rounded,
                  color: AppColors.mossGreen,
                ),
                loading: () => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Chữ Hán',
                ),
                error: (e, _) => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Chữ Hán',
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.sp8),
              child: KanjiLevelSelector(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp16,
                vertical: AppSpacing.sp8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: LibraryActionButton(
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
                        final dueCards = dueCardsAsync.valueOrNull;
                        if (dueCards != null && dueCards.isNotEmpty) {
                          Navigator.push(
                            context,
                            AppRoutes.review(
                              dueCards.map(ReviewItem.fromKanji).toList(),
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
                  Expanded(
                    child: LibraryActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Bài mới',
                      sublabel: 'Lộ trình học',
                      color: AppColors.mossGreen,
                      onTap: () {
                        final openLearningCategory = onOpenLearningCategory;
                        if (openLearningCategory != null) {
                          openLearningCategory(LearningCategory.kanji);
                        } else {
                          Navigator.push(
                            context,
                            AppRoutes.learningPath(
                              initialCategory: LearningCategory.kanji,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: KanjiLibrarySearchBar()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp8,
                AppSpacing.sp16,
                AppSpacing.sp4,
              ),
              child: Text(
                selectedLevel == null
                    ? 'Tất cả chữ Hán'
                    : 'Chữ Hán N$selectedLevel',
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.slateGrey,
                ),
              ),
            ),
          ),

          const KanjiGridView(),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp48)),
        ],
      ),
    );
  }
}
