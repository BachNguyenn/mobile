import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/progress_models.dart';
import '../../../../shared/widgets/progress_card.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../presentation/providers/learning_path_provider.dart';
import '../../../../presentation/screens/learning_path_screen.dart';
import '../providers/vocabulary_library_provider.dart';
import '../widgets/vocabulary_app_bar.dart';
import '../widgets/vocabulary_search_bar.dart';
import '../widgets/vocabulary_level_selector.dart';
import '../widgets/vocabulary_list_item.dart';
import '../widgets/vocabulary_empty_state.dart';

class VocabularyLibraryScreen extends ConsumerWidget {
  const VocabularyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(vocabularySearchResultsProvider);
    final progressAsync = ref.watch(vocabularyProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const VocabularyAppBar(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp16, AppSpacing.sp16, AppSpacing.sp8),
              child: progressAsync.when(
                data: (progress) => LibraryProgressCard(
                  progress: progress,
                  dueCount: 0,
                  title: 'Từ vựng',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.waterBlue,
                ),
                loading: () => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Từ vựng',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.waterBlue,
                ),
                error: (e, _) => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Từ vựng',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.waterBlue,
                ),
              ),
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
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.auto_stories_rounded,
                      label: 'Ôn tập',
                      sublabel: 'Tạm chưa khả dụng',
                      color: AppColors.terracotta,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp12),
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Bài mới',
                      sublabel: 'Lộ trình học',
                      color: AppColors.waterBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningPathScreen(
                              isNavBarMode: true,
                              initialCategory: LearningCategory.vocabulary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.sp8),
              child: VocabularyLevelSelector(),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp8, AppSpacing.sp16, AppSpacing.sp8),
              child: VocabularySearchBar(),
            ),
          ),

          // ── Section Title ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp8, AppSpacing.sp16, AppSpacing.sp4),
              child: Text(
                'Tất cả từ vựng',
                style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
              ),
            ),
          ),

          searchResults.when(
            data: (vocabList) {
              if (vocabList.isEmpty) {
                return const SliverFillRemaining(
                  child: VocabularyEmptyState(),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return VocabularyListItem(vocabulary: vocabList[index]);
                    },
                    childCount: vocabList.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Lỗi: $e'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp48)),
        ],
      ),
    );
  }
}
