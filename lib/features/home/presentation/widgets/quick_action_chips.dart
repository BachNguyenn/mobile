import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_library_provider.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_library_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';

typedef LearningCategoryCallback = void Function(LearningCategory category);

class QuickActionChips extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext context;
  final LearningCategoryCallback? onOpenLearningCategory;

  const QuickActionChips({
    super.key,
    required this.ref,
    required this.context,
    this.onOpenLearningCategory,
  });

  @override
  State<QuickActionChips> createState() => _QuickActionChipsState();
}

class _QuickActionChipsState extends State<QuickActionChips>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext outerContext) {
    final chips = [
      _ChipData(
        icon: Icons.add_circle_outline_rounded,
        label: 'Bài mới',
        color: AppColors.mossGreen,
        gradient: LinearGradient(
          colors: [
            AppColors.mossGreen.withValues(alpha: 0.08),
            AppColors.mossLight.withValues(alpha: 0.12),
          ],
        ),
        onTap: () {
          final openLearningCategory = widget.onOpenLearningCategory;
          if (openLearningCategory != null) {
            openLearningCategory(LearningCategory.mixed);
          } else {
            Navigator.push(widget.context, AppRoutes.learningPath());
          }
        },
      ),
      _ChipData(
        icon: Icons.bar_chart_rounded,
        label: 'Thống kê',
        color: AppColors.sunGold,
        gradient: LinearGradient(
          colors: [
            AppColors.sunGold.withValues(alpha: 0.08),
            AppColors.sunGold.withValues(alpha: 0.14),
          ],
        ),
        onTap: () {
          Navigator.push(widget.context, AppRoutes.analytics());
        },
      ),
      _ChipData(
        icon: Icons.psychology_rounded,
        label: 'Phân tích AI',
        color: const Color(0xFF9B7EDC),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B7EDC).withValues(alpha: 0.08),
            const Color(0xFF9B7EDC).withValues(alpha: 0.14),
          ],
        ),
        onTap: () {
          Navigator.push(widget.context, AppRoutes.grammarAnalysis());
        },
      ),
      _ChipData(
        icon: Icons.track_changes_rounded,
        label: 'Luyện điểm yếu',
        color: AppColors.terracotta,
        gradient: LinearGradient(
          colors: [
            AppColors.terracotta.withValues(alpha: 0.08),
            AppColors.terracotta.withValues(alpha: 0.14),
          ],
        ),
        onTap: () async {
          await _openWeakAreaReview(widget.context, widget.ref);
        },
      ),
      _ChipData(
        icon: Icons.subject_rounded,
        label: 'Luyện câu',
        color: AppColors.waterBlue,
        gradient: LinearGradient(
          colors: [
            AppColors.waterBlue.withValues(alpha: 0.08),
            AppColors.waterBlue.withValues(alpha: 0.14),
          ],
        ),
        onTap: () {
          Navigator.push(widget.context, AppRoutes.sentencePractice());
        },
      ),
      _ChipData(
        icon: Icons.search_rounded,
        label: 'Tra cứu',
        color: AppColors.slateGrey,
        gradient: LinearGradient(
          colors: [
            AppColors.slateGrey.withValues(alpha: 0.05),
            AppColors.slateGrey.withValues(alpha: 0.10),
          ],
        ),
        onTap: () {
          Navigator.push(widget.context, AppRoutes.dictionary());
        },
      ),
    ];

    return SizedBox(
      height: AppSpacing.quickActionChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingH24,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp12),
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              final delay = index * 0.15;
              final progress = ((_shimmerController.value - delay) / 0.5).clamp(
                0.0,
                1.0,
              );
              return Transform.translate(
                offset: Offset(
                  0,
                  12 * (1 - Curves.easeOutCubic.transform(progress)),
                ),
                child: Opacity(opacity: progress, child: child),
              );
            },
            child: _ActionChip(data: chips[index]),
          );
        },
      ),
    );
  }
}

Future<void> _openWeakAreaReview(BuildContext context, WidgetRef ref) async {
  final analytics = await ref.read(analyticsProvider.future);
  final weakestAreaType = analytics.weakestAreaType;
  if (weakestAreaType == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chưa đủ dữ liệu để gợi ý mảng yếu nhất.')),
    );
    return;
  }

  List<ReviewItem> items = const [];
  if (weakestAreaType == 'kanji') {
    final due = await ref.read(dueKanjiCardsProvider.future);
    items = due.map(ReviewItem.fromKanji).toList();
  } else if (weakestAreaType == 'vocabulary' || weakestAreaType == 'vocab') {
    final due = await ref.read(dueVocabularyProvider.future);
    items = due.map((v) => ReviewItem.fromVocabulary(v)).toList();
  } else if (weakestAreaType == 'grammar') {
    final due = await ref.read(dueGrammarProvider.future);
    items = due.map(ReviewItem.fromGrammar).toList();
  }

  if (!context.mounted) return;
  if (items.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mảng yếu hiện không có thẻ đến hạn.')),
    );
    return;
  }
  Navigator.push(context, AppRoutes.review(items));
}

class _ActionChip extends StatefulWidget {
  final _ChipData data;

  const _ActionChip({required this.data});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.data.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
          decoration: BoxDecoration(
            gradient: widget.data.gradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color: widget.data.color.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.data.color.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with subtle glow ring
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.data.color.withValues(alpha: 0.1),
                ),
                child: Icon(
                  widget.data.icon,
                  size: 16,
                  color: widget.data.color,
                ),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                widget.data.label,
                style: AppTypography.label.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  final LinearGradient gradient;
  final VoidCallback onTap;

  _ChipData({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });
}
