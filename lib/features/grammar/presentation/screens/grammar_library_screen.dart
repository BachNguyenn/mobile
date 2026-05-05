import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/progress_models.dart';
import '../providers/grammar_library_provider.dart';
import '../../../../shared/widgets/progress_card.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../shared/widgets/library_sliver_app_bar.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/jlpt_level_selector.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';

class GrammarLibraryScreen extends ConsumerWidget {
  final ValueChanged<LearningCategory>? onOpenLearningCategory;

  const GrammarLibraryScreen({super.key, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(
      grammarSearchResultsProvider(ref.watch(grammarSearchQueryProvider)),
    );
    final progressAsync = ref.watch(grammarProgressProvider);
    final dueGrammarAsync = ref.watch(dueGrammarProvider);
    final totalDueAsync = ref.watch(totalDueGrammarCountProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const LibrarySliverAppBar(
            title: 'Thư viện Ngữ pháp',
            heroTag: 'grammar_card',
          ),

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
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
                loading: () => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
                error: (e, _) => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp8),
              child: JlptLevelSelector(
                selectedLevel: ref.watch(grammarLevelFilterProvider),
                accentColor: AppColors.sunGold,
                onChanged: (level) =>
                    ref.read(grammarLevelFilterProvider.notifier).state = level,
              ),
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
                            : 'Học ${dueGrammarAsync.valueOrNull?.length ?? 0}/$totalDue điểm',
                        loading: () => 'Đang tải...',
                        error: (e, _) => 'Lỗi',
                      ),
                      color: AppColors.terracotta,
                      onTap: () {
                        final dueGrammar = dueGrammarAsync.valueOrNull;
                        if (dueGrammar != null && dueGrammar.isNotEmpty) {
                          Navigator.push(
                            context,
                            AppRoutes.review(
                              dueGrammar.map(ReviewItem.fromGrammar).toList(),
                            ),
                          );
                        } else if (dueGrammar != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không có ngữ pháp nào cần ôn tập!',
                              ),
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
                      color: AppColors.sunGold,
                      onTap: () {
                        final openLearningCategory = onOpenLearningCategory;
                        if (openLearningCategory != null) {
                          openLearningCategory(LearningCategory.grammar);
                        } else {
                          Navigator.push(
                            context,
                            AppRoutes.learningPath(
                              initialCategory: LearningCategory.grammar,
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
                    ref.read(grammarSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm điểm ngữ pháp...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.sunGold,
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
                      color: AppColors.sunGold,
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
                'Tất cả ngữ pháp',
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.slateGrey,
                ),
              ),
            ),
          ),

          searchResults.when(
            data: (grammarList) {
              if (grammarList.isEmpty) {
                return AppEmptyState.sliver(
                  message: 'Không tìm thấy ngữ pháp nào.',
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final grammar = grammarList[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
                      color: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                        side: BorderSide(
                          color: AppColors.slateLight.withValues(alpha: 0.2),
                        ),
                      ),
                      child: ExpansionTile(
                        shape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        collapsedShape: const RoundedRectangleBorder(
                          side: BorderSide.none,
                        ),
                        title: Text(
                          grammar.title,
                          style: AppTypography.headingS.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        subtitle: Text(
                          grammar.shortExplanation,
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.slateGrey,
                          ),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sunGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusS,
                            ),
                          ),
                          child: Text(
                            'N${grammar.jlptLevel}',
                            style: AppTypography.bodyMBold.copyWith(
                              color: AppColors.sunGold,
                            ),
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.sp16),
                            decoration: BoxDecoration(
                              color: AppColors.cream.withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(AppSpacing.radiusM),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSection('Cấu trúc', grammar.formation),
                                const SizedBox(height: AppSpacing.sp12),
                                _buildSection(
                                  'Giải thích',
                                  grammar.longExplanation,
                                ),
                                const SizedBox(height: AppSpacing.sp12),
                                Text(
                                  'Ví dụ:',
                                  style: AppTypography.bodyMBold.copyWith(
                                    color: AppColors.sunGold,
                                  ),
                                ),
                                ...grammar.examples.map(
                                  (ex) => Padding(
                                    padding: const EdgeInsets.only(top: AppSpacing.sp4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• ${ex.jp}',
                                          style: AppTypography.bodyM.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (ex.en.isNotEmpty)
                                          Text(
                                            '  ${ex.en}',
                                            style: AppTypography.bodyS.copyWith(
                                              color: AppColors.slateMuted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: grammarList.length),
                ),
              );
            },
            loading: () => AppLoadingIndicator.sliver(),
            error: (e, _) => AppEmptyState.sliver(
              icon: Icons.error_outline_rounded,
              message: 'Lỗi: $e',
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp48)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title:',
          style: AppTypography.bodyMBold.copyWith(color: AppColors.sunGold),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(content, style: AppTypography.bodyM),
      ],
    );
  }
}
