import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

import '../providers/vocabulary_library_provider.dart';
import '../widgets/vocabulary_list_item.dart';
import '../widgets/vocabulary_search_bar.dart';

class VocabularyLibraryScreen extends ConsumerWidget {
  final ValueChanged<LearningCategory>? onOpenLearningCategory;

  const VocabularyLibraryScreen({super.key, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(vocabularySearchQueryProvider);
    final selectedLevel = ref.watch(vocabularyLevelFilterProvider);
    final searchResults = ref.watch(vocabularySearchResultsProvider(query));
    final progressAsync = ref.watch(vocabularyProgressProvider);
    final dueVocabularyAsync = ref.watch(dueVocabularyProvider);
    final totalDueAsync = ref.watch(totalDueVocabularyCountProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppPageBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    AppSpacing.sp8,
                    AppSpacing.sp16,
                    AppSpacing.sp12,
                  ),
                  child: _VocabularyTopBar(selectedLevel: selectedLevel),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp16,
                  ),
                  child: _VocabularyHeroCard(
                    progress: progressAsync.valueOrNull ?? ModuleProgress.empty,
                    dueTotal: totalDueAsync.valueOrNull ?? 0,
                    dueLoaded: dueVocabularyAsync.valueOrNull?.length ?? 0,
                    isLoading:
                        progressAsync.isLoading || totalDueAsync.isLoading,
                    onReview: () => _startReview(
                      context,
                      dueVocabularyAsync.valueOrNull,
                      searchResults.valueOrNull,
                    ),
                    onNewLesson: () => _openLearningPath(context),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                    AppSpacing.sp8,
                  ),
                  child: VocabularySearchBar(),
                ),
              ),
              SliverToBoxAdapter(
                child: _VocabularyLevelRail(
                  selectedLevel: selectedLevel,
                  onChanged: (level) =>
                      ref.read(vocabularyLevelFilterProvider.notifier).state =
                          level,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                    AppSpacing.sp8,
                  ),
                  child: _VocabularySectionHeader(
                    count: searchResults.valueOrNull?.length,
                    query: query,
                  ),
                ),
              ),
              searchResults.when(
                data: (vocabList) {
                  if (vocabList.isEmpty) {
                    return AppEmptyState.sliver(
                      icon: Icons.search_off_rounded,
                      message: query.trim().isEmpty
                          ? 'Chưa có từ vựng cho bộ lọc này.'
                          : 'Không tìm thấy từ vựng phù hợp.',
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == vocabList.length - 1
                                ? 0
                                : AppSpacing.sp12,
                          ),
                          child: VocabularyListItem(
                            vocabulary: vocabList[index],
                          ),
                        );
                      }, childCount: vocabList.length),
                    ),
                  );
                },
                loading: () => AppLoadingIndicator.sliver(),
                error: (e, _) => AppEmptyState.sliver(
                  icon: Icons.error_outline_rounded,
                  message: 'Lỗi: $e',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }

  void _openLearningPath(BuildContext context) {
    if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;

    final openLearningCategory = onOpenLearningCategory;
    if (openLearningCategory != null) {
      openLearningCategory(LearningCategory.vocabulary);
      return;
    }

    Navigator.push(
      context,
      AppRoutes.learningPath(initialCategory: LearningCategory.vocabulary),
    );
  }

  void _startReview(
    BuildContext context,
    List<Vocabulary>? dueVocabulary,
    List<Vocabulary>? allVocabulary,
  ) {
    if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;

    if (dueVocabulary == null) return;
    if (dueVocabulary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có từ vựng nào cần ôn tập!')),
      );
      return;
    }

    Navigator.push(
      context,
      AppRoutes.review(
        _buildVocabularyReviewItems(
          dueVocabulary,
          allVocabulary ?? dueVocabulary,
        ),
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

class _VocabularyTopBar extends StatelessWidget {
  final int? selectedLevel;

  const _VocabularyTopBar({required this.selectedLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.navySoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          ),
          child: const Icon(Icons.menu_book_rounded, color: AppColors.navy),
        ),
        const SizedBox(width: AppSpacing.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Từ vựng',
                style: AppTypography.headingM.copyWith(
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedLevel == null
                    ? 'Tất cả cấp độ JLPT'
                    : 'Đang học JLPT N$selectedLevel',
                style: AppTypography.label.copyWith(
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VocabularyHeroCard extends StatelessWidget {
  final ModuleProgress progress;
  final int dueTotal;
  final int dueLoaded;
  final bool isLoading;
  final VoidCallback onReview;
  final VoidCallback onNewLesson;

  const _VocabularyHeroCard({
    required this.progress,
    required this.dueTotal,
    required this.dueLoaded,
    required this.isLoading,
    required this.onReview,
    required this.onNewLesson,
  });

  @override
  Widget build(BuildContext context) {
    final learned = progress.learned;
    final total = progress.total;
    final percent = total == 0 ? 0.0 : progress.percentage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.waterBlue, AppColors.leafGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -16,
            child: Icon(
              Icons.style_rounded,
              size: 104,
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Kho từ hôm nay',
                      style: AppTypography.headingS.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  _HeroBadge(
                    icon: Icons.inventory_2_rounded,
                    label: dueTotal == 0 ? 'Đã xong' : '$dueTotal cần ôn',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                'Ôn từ cũ, thêm từ mới và giữ nhịp học tiếng Nhật mỗi ngày.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.white.withValues(alpha: 0.78),
                ),
              ),
              const SizedBox(height: AppSpacing.sp12),
              Row(
                children: [
                  _HeroStat(value: '$learned', label: 'đã học'),
                  const SizedBox(width: AppSpacing.sp8),
                  _HeroStat(value: '$total', label: 'tổng từ'),
                  const SizedBox(width: AppSpacing.sp8),
                  _HeroStat(
                    value: isLoading ? '...' : '$dueLoaded',
                    label: 'sẵn sàng',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppColors.white.withValues(alpha: 0.16),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.leafLight,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp12),
              Row(
                children: [
                  Expanded(
                    child: _HeroActionButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Ôn kho từ',
                      filled: true,
                      onTap: onReview,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Expanded(
                    child: _HeroActionButton(
                      icon: Icons.add_card_rounded,
                      label: 'Thêm từ',
                      filled: false,
                      onTap: onNewLesson,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 14),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.labelS.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp8),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.bodyMBold.copyWith(
                color: AppColors.white,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelS.copyWith(
                color: AppColors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp12,
            vertical: AppSpacing.sp8,
          ),
          decoration: BoxDecoration(
            color: filled
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? AppColors.navy : AppColors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: filled ? AppColors.navy : AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VocabularyLevelRail extends StatelessWidget {
  final int? selectedLevel;
  final ValueChanged<int?> onChanged;

  const _VocabularyLevelRail({
    required this.selectedLevel,
    required this.onChanged,
  });

  static const _levels = <int?>[null, 5, 4, 3, 2, 1];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        scrollDirection: Axis.horizontal,
        itemCount: _levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp8),
        itemBuilder: (context, index) {
          final level = _levels[index];
          final selected = selectedLevel == level;
          final label = level == null ? 'Tất cả' : 'N$level';
          return ChoiceChip(
            selected: selected,
            label: Text(label),
            showCheckmark: false,
            onSelected: (_) =>
                onChanged(selected && level != null ? null : level),
            labelStyle: AppTypography.label.copyWith(
              color: selected ? AppColors.white : AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: AppColors.white,
            selectedColor: AppColors.leafGreen,
            side: BorderSide(
              color: selected
                  ? AppColors.leafGreen
                  : AppColors.slateLight.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            ),
          );
        },
      ),
    );
  }
}

class _VocabularySectionHeader extends StatelessWidget {
  final int? count;
  final String query;

  const _VocabularySectionHeader({required this.count, required this.query});

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasQuery ? 'Kết quả tìm kiếm' : 'Thẻ từ vựng',
                style: AppTypography.headingS.copyWith(
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                hasQuery
                    ? 'Các từ khớp với "$query".'
                    : 'Quét nhanh từ, nghĩa tiếng Việt và câu ví dụ.',
                style: AppTypography.bodyS.copyWith(
                  color: AppColors.slateMuted,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp12,
            vertical: AppSpacing.sp8,
          ),
          decoration: BoxDecoration(
            color: AppColors.navySoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          ),
          child: Text(
            count == null ? '...' : '$count từ',
            style: AppTypography.label.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
