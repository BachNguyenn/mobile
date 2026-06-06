import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/weakness/application/providers/weakness_provider.dart';
import 'package:mobile/features/weakness/domain/entities/weakness_review_item.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_selector.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class WeaknessScreen extends ConsumerWidget {
  const WeaknessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(weakItemsProvider);
    final reviewItemsAsync = ref.watch(weakReviewItemsProvider);
    final selectedLevel = ref.watch(weaknessLevelFilterProvider);
    final selectedType = ref.watch(weaknessTypeFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục hay sai', style: AppTypography.headingM),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.sp8),
              JlptLevelSelector(
                selectedLevel: selectedLevel,
                accentColor: AppColors.terracotta,
                onChanged: (level) {
                  ref.read(weaknessLevelFilterProvider.notifier).state = level;
                },
              ),
              const SizedBox(height: AppSpacing.sp8),
              _TypeFilter(
                selected: selectedType,
                onChanged: (type) {
                  ref.read(weaknessTypeFilterProvider.notifier).state = type;
                },
              ),
              const SizedBox(height: AppSpacing.sp8),
              Expanded(
                child: itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'Chưa đủ dữ liệu lỗi sai',
                        message:
                            'Hãy ôn thêm vài phiên. Các mục trả lời sai nhiều sẽ xuất hiện ở đây.',
                      );
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sp16,
                        AppSpacing.sp8,
                        AppSpacing.sp16,
                        104,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sp8),
                      itemBuilder: (context, index) {
                        return _WeaknessTile(item: items[index]);
                      },
                    );
                  },
                  loading: () =>
                      const AppLoadingIndicator(color: AppColors.terracotta),
                  error: (error, _) => AppEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Không tải được sổ lỗi',
                    message: '$error',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp8,
            AppSpacing.sp16,
            AppSpacing.sp16,
          ),
          child: PrimaryButton(
            icon: Icons.psychology_alt_rounded,
            color: AppColors.terracotta,
            label: 'Luyện lại 10 mục yếu',
            onPressed: reviewItemsAsync.maybeWhen(
              data: (items) {
                if (items.isEmpty) return null;
                return () => Navigator.push(context, AppRoutes.review(items));
              },
              orElse: () => null,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeFilter extends StatelessWidget {
  final ReviewItemType? selected;
  final ValueChanged<ReviewItemType?> onChanged;

  const _TypeFilter({required this.selected, required this.onChanged});

  static const _items = [
    (null, Icons.all_inclusive_rounded, 'Tất cả'),
    (ReviewItemType.vocabulary, Icons.menu_book_rounded, 'Từ vựng'),
    (ReviewItemType.grammar, Icons.edit_note_rounded, 'Ngữ pháp'),
    (ReviewItemType.kanji, Icons.translate_rounded, 'Chữ Hán'),
  ];

  @override
  Widget build(BuildContext context) {
    final resolvedTerracotta = AppColors.resolve(AppColors.terracotta, context);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp8),
        itemBuilder: (context, index) {
          final (type, icon, label) = _items[index];
          final isSelected = selected == type;
          return ChoiceChip(
            selected: isSelected,
            avatar: Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.white : resolvedTerracotta,
            ),
            label: Text(label),
            showCheckmark: false,
            onSelected: (_) =>
                onChanged(isSelected && type != null ? null : type),
            labelStyle: AppTypography.label.copyWith(
              color: isSelected
                  ? AppColors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: Theme.of(context).cardColor,
            selectedColor: resolvedTerracotta,
            side: BorderSide(
              color: isSelected
                  ? resolvedTerracotta
                  : Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.55),
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

class _WeaknessTile extends StatelessWidget {
  final WeaknessReviewItem item;

  const _WeaknessTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.resolve(_accentFor(item.type), context);
    final review = item.reviewItem;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp12),
      borderColor: accent.withValues(alpha: 0.18),
      shadowColor: accent.withValues(alpha: 0.04),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: Icon(_iconFor(item.type), color: accent),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _titleFor(review),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyMBold.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    Text(
                      'N${review.jlptLevel}',
                      style: AppTypography.label.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  _subtitleFor(review),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sp8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                        child: LinearProgressIndicator(
                          value: item.successRate.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: AppColors.resolve(
                            AppColors.creamDark,
                            context,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Text(
                      '${item.misses}/${item.attempts} sai',
                      style: AppTypography.labelS.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _titleFor(ReviewItem item) {
    return switch (item.type) {
      ReviewItemType.kanji => item.answer,
      ReviewItemType.vocabulary => item.prompt,
      ReviewItemType.grammar => item.grammar?.title ?? item.prompt,
      ReviewItemType.sentence => item.prompt,
    };
  }

  String _subtitleFor(ReviewItem item) {
    return switch (item.type) {
      ReviewItemType.kanji => item.prompt,
      ReviewItemType.vocabulary => '${item.subtitle ?? ''} · ${item.answer}',
      ReviewItemType.grammar => item.answer,
      ReviewItemType.sentence => item.answer,
    };
  }

  IconData _iconFor(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.kanji => Icons.brush_rounded,
      ReviewItemType.vocabulary => Icons.menu_book_rounded,
      ReviewItemType.grammar => Icons.edit_note_rounded,
      ReviewItemType.sentence => Icons.subject_rounded,
    };
  }

  Color _accentFor(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.kanji => AppColors.waterBlue,
      ReviewItemType.vocabulary => AppColors.zenBlue,
      ReviewItemType.grammar => AppColors.terracotta,
      ReviewItemType.sentence => AppColors.leafGreen,
    };
  }
}
