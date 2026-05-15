import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';

import '../providers/grammar_library_provider.dart';

class GrammarLibraryScreen extends ConsumerWidget {
  final ValueChanged<LearningCategory>? onOpenLearningCategory;

  const GrammarLibraryScreen({super.key, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(grammarSearchQueryProvider);
    final selectedLevel = ref.watch(grammarLevelFilterProvider);
    final searchResults = ref.watch(grammarSearchResultsProvider(query));
    final progressAsync = ref.watch(grammarProgressProvider);
    final dueGrammarAsync = ref.watch(dueGrammarProvider);
    final totalDueAsync = ref.watch(totalDueGrammarCountProvider);

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
                  child: _GrammarTopBar(selectedLevel: selectedLevel),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp16,
                  ),
                  child: _GrammarHeroCard(
                    progress: progressAsync.valueOrNull ?? ModuleProgress.empty,
                    dueTotal: totalDueAsync.valueOrNull ?? 0,
                    dueLoaded: dueGrammarAsync.valueOrNull?.length ?? 0,
                    isLoading:
                        progressAsync.isLoading || totalDueAsync.isLoading,
                    onReview: () =>
                        _startReview(context, dueGrammarAsync.valueOrNull),
                    onNewLesson: () => _openLearningPath(context),
                    onSentencePractice: () =>
                        Navigator.push(context, AppRoutes.sentencePractice()),
                  ),
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
                  child: _GrammarSearchBox(
                    onChanged: (value) =>
                        ref.read(grammarSearchQueryProvider.notifier).state =
                            value,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _GrammarLevelRail(
                  selectedLevel: selectedLevel,
                  onChanged: (level) =>
                      ref.read(grammarLevelFilterProvider.notifier).state =
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
                  child: _GrammarSectionHeader(
                    count: searchResults.valueOrNull?.length,
                    query: query,
                  ),
                ),
              ),
              searchResults.when(
                data: (grammarList) {
                  if (grammarList.isEmpty) {
                    return AppEmptyState.sliver(
                      icon: Icons.search_off_rounded,
                      message: query.trim().isEmpty
                          ? 'Chưa có ngữ pháp cho bộ lọc này.'
                          : 'Không tìm thấy điểm ngữ pháp phù hợp.',
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp16,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final grammar = grammarList[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == grammarList.length - 1
                                ? 0
                                : AppSpacing.sp12,
                          ),
                          child: _GrammarPatternCard(grammar: grammar),
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
      openLearningCategory(LearningCategory.grammar);
      return;
    }

    Navigator.push(
      context,
      AppRoutes.learningPath(initialCategory: LearningCategory.grammar),
    );
  }

  void _startReview(BuildContext context, List<GrammarPoint>? dueGrammar) {
    if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;

    if (dueGrammar == null) return;
    if (dueGrammar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có ngữ pháp nào cần ôn tập!')),
      );
      return;
    }

    Navigator.push(context, AppRoutes.grammarReview(dueGrammar));
  }
}

class _GrammarTopBar extends StatelessWidget {
  final int? selectedLevel;

  const _GrammarTopBar({required this.selectedLevel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.leafGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          ),
          child: const Icon(Icons.edit_note_rounded, color: AppColors.leafDark),
        ),
        const SizedBox(width: AppSpacing.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ngữ pháp',
                style: AppTypography.headingM.copyWith(
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedLevel == null
                    ? 'Mẫu câu theo cấp độ JLPT'
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

class _GrammarHeroCard extends StatelessWidget {
  final ModuleProgress progress;
  final int dueTotal;
  final int dueLoaded;
  final bool isLoading;
  final VoidCallback onReview;
  final VoidCallback onNewLesson;
  final VoidCallback onSentencePractice;

  const _GrammarHeroCard({
    required this.progress,
    required this.dueTotal,
    required this.dueLoaded,
    required this.isLoading,
    required this.onReview,
    required this.onNewLesson,
    required this.onSentencePractice,
  });

  @override
  Widget build(BuildContext context) {
    final percent = progress.total == 0
        ? 0.0
        : progress.percentage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: BoxDecoration(
        gradient: AppColors.brandLeafGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ôn ý nghĩa ngữ pháp',
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              _HeroBadge(
                icon: Icons.task_alt_rounded,
                label: dueTotal == 0 ? 'Đã xong' : '$dueTotal cần học',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Tự nhớ mẫu này dùng để nói ý gì, sau đó đối chiếu cấu trúc và ví dụ.',
            style: AppTypography.bodyS.copyWith(
              color: AppColors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: AppSpacing.sp20),
          Row(
            children: [
              _HeroStat(value: '${progress.learned}', label: 'đã học'),
              const SizedBox(width: AppSpacing.sp12),
              _HeroStat(value: '${progress.total}', label: 'tổng mẫu'),
              const SizedBox(width: AppSpacing.sp12),
              _HeroStat(
                value: isLoading ? '...' : '$dueLoaded',
                label: 'sẵn sàng',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.leafLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp16),
          Row(
            children: [
              Expanded(
                child: _HeroActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Ôn ý',
                  filled: true,
                  onTap: onReview,
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: _HeroActionButton(
                  icon: Icons.add_rounded,
                  label: 'Bài mới',
                  filled: false,
                  onTap: onNewLesson,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          _SentencePracticeButton(onTap: onSentencePractice),
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
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white, size: 16),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.label.copyWith(
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
        padding: const EdgeInsets.all(AppSpacing.sp12),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.headingS.copyWith(color: AppColors.white),
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
            horizontal: AppSpacing.sp16,
            vertical: AppSpacing.sp12,
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
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                label,
                style: AppTypography.bodyMBold.copyWith(
                  color: filled ? AppColors.navy : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SentencePracticeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SentencePracticeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: AppSpacing.sp12,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.subject_rounded,
                color: AppColors.white,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                'Luyện câu',
                style: AppTypography.bodyMBold.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrammarSearchBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _GrammarSearchBox({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTypography.bodyM.copyWith(
        color: AppColors.navyDark,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Tìm mẫu câu, ý nghĩa hoặc ví dụ...',
        hintStyle: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.leafGreen,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide(
            color: AppColors.slateLight.withValues(alpha: 0.32),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: const BorderSide(color: AppColors.leafGreen, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp16,
          vertical: AppSpacing.sp16,
        ),
      ),
    );
  }
}

class _GrammarLevelRail extends StatelessWidget {
  final int? selectedLevel;
  final ValueChanged<int?> onChanged;

  const _GrammarLevelRail({
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

class _GrammarSectionHeader extends StatelessWidget {
  final int? count;
  final String query;

  const _GrammarSectionHeader({required this.count, required this.query});

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
                hasQuery ? 'Kết quả tìm kiếm' : 'Mẫu ngữ pháp',
                style: AppTypography.headingS.copyWith(
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Text(
                hasQuery
                    ? 'Các mẫu khớp với "$query".'
                    : 'Mở từng mẫu để xem cấu trúc, giải thích và ví dụ.',
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
            count == null ? '...' : '$count mẫu',
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

class _GrammarPatternCard extends StatelessWidget {
  final GrammarPoint grammar;

  const _GrammarPatternCard({required this.grammar});

  @override
  Widget build(BuildContext context) {
    final firstExample = grammar.examples.isNotEmpty
        ? grammar.examples.first
        : null;
    final explanation = grammar.longExplanation.isNotEmpty
        ? grammar.longExplanation
        : grammar.shortExplanation;

    return AppCard(
      padding: EdgeInsets.zero,
      color: AppColors.white,
      borderColor: AppColors.slateLight.withValues(alpha: 0.28),
      shadowColor: AppColors.navyDark.withValues(alpha: 0.035),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.leafGreen.withValues(alpha: 0.06),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp12,
            AppSpacing.sp16,
            AppSpacing.sp12,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            0,
            AppSpacing.sp16,
            AppSpacing.sp16,
          ),
          leading: JlptLevelBadge(
            level: grammar.jlptLevel,
            color: AppColors.leafGreen,
          ),
          title: Text(
            grammar.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headingS.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sp4),
            child: Text(
              grammar.shortExplanation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
            ),
          ),
          children: [
            if (grammar.formation.isNotEmpty) ...[
              _FormationBlock(text: grammar.formation),
              const SizedBox(height: AppSpacing.sp12),
            ],
            _ExplanationBlock(text: explanation),
            if (firstExample != null) ...[
              const SizedBox(height: AppSpacing.sp12),
              _ExampleBlock(example: firstExample),
            ],
            if (grammar.examples.length > 1) ...[
              const SizedBox(height: AppSpacing.sp8),
              ...grammar.examples
                  .skip(1)
                  .map(
                    (example) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                      child: _ExampleBlock(example: example),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FormationBlock extends StatelessWidget {
  final String text;

  const _FormationBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.leafGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.leafGreen.withValues(alpha: 0.10)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTypography.bodyL.copyWith(
          color: AppColors.leafDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExplanationBlock extends StatelessWidget {
  final String text;

  const _ExplanationBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _BlockLabel(icon: Icons.notes_rounded, label: 'Giải thích'),
        const SizedBox(height: AppSpacing.sp8),
        Text(
          text,
          style: AppTypography.bodyM.copyWith(
            color: AppColors.navyDark,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final GrammarExample example;

  const _ExampleBlock({required this.example});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.navySoft.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlockLabel(icon: Icons.format_quote_rounded, label: 'Ví dụ'),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            example.jp,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (example.romaji.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              example.romaji,
              style: AppTypography.label.copyWith(
                color: AppColors.slateMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (example.en.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              example.en,
              style: AppTypography.label.copyWith(color: AppColors.slateMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _BlockLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BlockLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.leafGreen, size: 17),
        const SizedBox(width: AppSpacing.sp4),
        Text(
          label,
          style: AppTypography.labelS.copyWith(
            color: AppColors.leafDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
