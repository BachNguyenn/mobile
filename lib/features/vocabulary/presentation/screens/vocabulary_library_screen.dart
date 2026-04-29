import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/progress_models.dart';
import '../../../../shared/widgets/progress_card.dart';
import '../../../../shared/widgets/action_button.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import '../providers/vocabulary_library_provider.dart';
import '../widgets/vocabulary_app_bar.dart';
import '../widgets/vocabulary_search_bar.dart';
import '../widgets/vocabulary_level_selector.dart';
import '../widgets/vocabulary_list_item.dart';
import '../widgets/vocabulary_empty_state.dart';

class VocabularyLibraryScreen extends ConsumerWidget {
  final ValueChanged<LearningCategory>? onOpenLearningCategory;

  const VocabularyLibraryScreen({super.key, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(
      vocabularySearchResultsProvider(ref.watch(vocabularySearchQueryProvider)),
    );
    final progressAsync = ref.watch(vocabularyProgressProvider);
    final dueVocabularyAsync = ref.watch(dueVocabularyProvider);
    final totalDueAsync = ref.watch(totalDueVocabularyCountProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const VocabularyAppBar(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp16,
                AppSpacing.sp8,
              ),
              child: progressAsync.when(
                data: (progress) => LibraryProgressCard(
                  progress: progress,
                  dueCount: totalDueAsync.valueOrNull ?? 0,
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

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: AppSpacing.sp8),
              child: VocabularyLevelSelector(),
            ),
          ),

          // Action Buttons (Ôn tập + Bài mới)
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
                      sublabel: totalDueAsync.when(
                        data: (totalDue) => totalDue == 0
                            ? 'Đã hoàn thành'
                            : 'Học ${dueVocabularyAsync.valueOrNull?.length ?? 0}/$totalDue từ',
                        loading: () => 'Đang tải...',
                        error: (e, _) => 'Lỗi',
                      ),
                      color: AppColors.terracotta,
                      onTap: () {
                        final dueVocabulary = dueVocabularyAsync.valueOrNull;
                        if (dueVocabulary != null && dueVocabulary.isNotEmpty) {
                          final allVocabulary =
                              searchResults.valueOrNull ?? dueVocabulary;
                          Navigator.push(
                            context,
                            AppRoutes.review(
                              _buildVocabularyReviewItems(
                                dueVocabulary,
                                allVocabulary,
                              ),
                            ),
                          );
                        } else if (dueVocabulary != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không có từ vựng nào cần ôn tập!'),
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
                      color: AppColors.waterBlue,
                      onTap: () {
                        final openLearningCategory = onOpenLearningCategory;
                        if (openLearningCategory != null) {
                          openLearningCategory(LearningCategory.vocabulary);
                        } else {
                          Navigator.push(
                            context,
                            AppRoutes.learningPath(
                              initialCategory: LearningCategory.vocabulary,
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

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.sp16,
                AppSpacing.sp8,
                AppSpacing.sp16,
                AppSpacing.sp8,
              ),
              child: VocabularySearchBar(),
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
                'Tất cả từ vựng',
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.slateGrey,
                ),
              ),
            ),
          ),

          searchResults.when(
            data: (vocabList) {
              if (vocabList.isEmpty) {
                return const SliverFillRemaining(child: VocabularyEmptyState());
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return VocabularyListItem(vocabulary: vocabList[index]);
                  }, childCount: vocabList.length),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text('Lỗi: $e'))),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp48)),
        ],
      ),
    );
  }

  List<ReviewItem> _buildVocabularyReviewItems(
    List<Vocabulary> dueVocabulary,
    List<Vocabulary> allVocabulary,
  ) {
    final allMeanings = allVocabulary
        .map((vocabulary) => vocabulary.meaning)
        .where((meaning) => meaning.isNotEmpty)
        .toList();

    return dueVocabulary.map((vocabulary) {
      final distractors = allMeanings
          .where((meaning) => meaning != vocabulary.meaning)
          .take(3)
          .toList();
      final choices = [...distractors, vocabulary.meaning]..shuffle();
      return ReviewItem.fromVocabulary(vocabulary, choices: choices);
    }).toList();
  }
}
