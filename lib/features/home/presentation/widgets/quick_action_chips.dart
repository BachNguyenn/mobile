import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/analytics/application/providers/analytics_provider.dart';
import 'package:mobile/features/grammar/application/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/application/providers/kanji_library_provider.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_library_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/feature_tile.dart';

typedef LearningCategoryCallback = void Function(LearningCategory category);
typedef TabSwitchCallback = void Function(int index);

class QuickActionChips extends StatefulWidget {
  final WidgetRef ref;
  final BuildContext context;
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const QuickActionChips({
    super.key,
    required this.ref,
    required this.context,
    this.onOpenTab,
    this.onOpenLearningCategory,
  });

  @override
  State<QuickActionChips> createState() => _QuickActionChipsState();
}

class _QuickActionChipsState extends State<QuickActionChips>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext outerContext) {
    final actions = [
      _ActionData(
        icon: Icons.menu_book_rounded,
        label: 'Từ vựng',
        helper: 'Xem thẻ từ mới',
        color: AppColors.waterBlue,
        onTap: () => widget.onOpenTab?.call(2),
      ),
      _ActionData(
        icon: Icons.edit_note_rounded,
        label: 'Ngữ pháp',
        helper: 'Mẫu câu dễ đọc',
        color: AppColors.sunGold,
        onTap: () => widget.onOpenTab?.call(3),
      ),
      _ActionData(
        icon: Icons.quiz_rounded,
        label: 'Quiz',
        helper: 'Tiếp tục lộ trình',
        color: AppColors.zenBlue,
        onTap: () {
          final openLearningCategory = widget.onOpenLearningCategory;
          if (openLearningCategory != null) {
            openLearningCategory(LearningCategory.mixed);
          } else {
            Navigator.push(widget.context, AppRoutes.learningPath());
          }
        },
      ),
      _ActionData(
        icon: Icons.replay_rounded,
        label: 'SRS Review',
        helper: 'Ôn mục đến hạn',
        color: AppColors.leafGreen,
        onTap: () async {
          await openWeakAreaReview(widget.context, widget.ref);
        },
      ),
      _ActionData(
        icon: Icons.task_alt_rounded,
        label: 'Nhiệm vụ',
        helper: 'Mục tiêu hôm nay',
        color: AppColors.terracotta,
        onTap: () {
          Navigator.push(widget.context, AppRoutes.garden());
        },
      ),
      _ActionData(
        icon: Icons.bar_chart_rounded,
        label: 'Hồ sơ',
        helper: 'Tiến độ học tập',
        color: AppColors.slateGrey,
        onTap: () {
          Navigator.push(widget.context, AppRoutes.analytics());
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.sp12;
        final itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(actions.length, (index) {
            final action = actions[index];
            return AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final raw = ((_entranceController.value - index * 0.07) / 0.45)
                    .clamp(0.0, 1.0);
                final curve = Curves.easeOutCubic.transform(raw);
                return Transform.translate(
                  offset: Offset(0, 12 * (1 - curve)),
                  child: Opacity(opacity: curve, child: child),
                );
              },
              child: SizedBox(
                width: itemWidth,
                child: FeatureTile(
                  icon: action.icon,
                  title: action.label,
                  subtitle: action.helper,
                  color: action.color,
                  onTap: action.onTap,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

Future<void> openWeakAreaReview(BuildContext context, WidgetRef ref) async {
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

class _ActionCard extends StatefulWidget {
  final _ActionData data;

  const _ActionCard({required this.data});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
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
          height: 78,
          padding: const EdgeInsets.all(AppSpacing.sp12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: widget.data.color.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: widget.data.color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                ),
                child: Icon(
                  widget.data.icon,
                  color: widget.data.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.data.helper,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelS,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final String helper;
  final Color color;
  final VoidCallback onTap;

  const _ActionData({
    required this.icon,
    required this.label,
    required this.helper,
    required this.color,
    required this.onTap,
  });
}
