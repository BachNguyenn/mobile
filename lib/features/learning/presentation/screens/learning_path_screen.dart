import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/presentation/screens/lesson_detail_screen.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_selector.dart';

class LearningPathScreen extends ConsumerStatefulWidget {
  final bool isNavBarMode;
  final LearningCategory? initialCategory;

  const LearningPathScreen({
    super.key,
    this.isNavBarMode = false,
    this.initialCategory,
  });

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  @override
  void initState() {
    super.initState();
    _scheduleApplyInitialCategory();
  }

  @override
  void didUpdateWidget(covariant LearningPathScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory ||
        oldWidget.isNavBarMode != widget.isNavBarMode) {
      _scheduleApplyInitialCategory();
    }
  }

  void _scheduleApplyInitialCategory() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _applyInitialCategory();
    });
  }

  void _applyInitialCategory() {
    final targetCategory = widget.initialCategory;
    if (targetCategory == null) return;
    if (ref.read(learningCategoryProvider) != targetCategory) {
      ref.read(learningCategoryProvider.notifier).state = targetCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessons = ref.watch(learningPathProvider);
    final category = ref.watch(learningCategoryProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);

    final levelLessons = lessons; // Already filtered by level in provider
    final completedCount = levelLessons
        .where((lesson) => lesson.isCompleted)
        .length;
    final currentLesson = _currentLesson(levelLessons);
    final continueLesson = currentLesson != null && currentLesson.isUnlocked
        ? currentLesson
        : null;
    final vocabCount = levelLessons.fold<int>(
      0,
      (total, lesson) => total + lesson.vocabIds.length,
    );
    final grammarCount = levelLessons.fold<int>(
      0,
      (total, lesson) => total + lesson.grammarIds.length,
    );
    final kanjiCount = levelLessons.fold<int>(
      0,
      (total, lesson) => total + lesson.kanjiIds.length,
    );
    final categorySpec = _LearningCategorySpec.from(category);
    final focusedItemCount = switch (category) {
      LearningCategory.vocabulary => vocabCount,
      LearningCategory.grammar => grammarCount,
      LearningCategory.kanji => kanjiCount,
      LearningCategory.mixed => vocabCount + grammarCount + kanjiCount,
    };

    return Scaffold(
      body: AppPageBackground(
        child: CustomScrollView(
          slivers: [
            _LearningPathAppBar(),
            if (category != LearningCategory.mixed)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sp12),
                    JlptLevelSelector(
                      selectedLevel: selectedLevel,
                      accentColor: AppColors.mossGreen,
                      onChanged: (level) {
                        if (level != null) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateCurrentJlptLevel(level);
                          ref.read(selectedLevelProvider.notifier).state =
                              level;
                        }
                      },
                      levels: const [5, 4, 3, 2, 1],
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                  ],
                ),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.sp12),
              ),
            if (category == LearningCategory.mixed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp24,
                    0,
                    AppSpacing.sp24,
                    AppSpacing.sp16,
                  ),
                  child: _LearningOverviewCard(
                    level: selectedLevel,
                    completed: completedCount,
                    total: levelLessons.length,
                    currentLesson: currentLesson,
                    onContinue: continueLesson == null
                        ? null
                        : () => _openLesson(context, continueLesson),
                  ),
                ),
              ),
            if (category == LearningCategory.mixed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp24,
                    0,
                    AppSpacing.sp24,
                    AppSpacing.sp16,
                  ),
                  child: _SkillMixStrip(
                    vocabCount: vocabCount,
                    grammarCount: grammarCount,
                    kanjiCount: kanjiCount,
                  ),
                ),
              ),
            if (category != LearningCategory.mixed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    0,
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                  ),
                  child: _FocusedLearningHero(
                    spec: categorySpec,
                    level: selectedLevel,
                    completed: completedCount,
                    total: levelLessons.length,
                    itemCount: focusedItemCount,
                    currentLesson: currentLesson,
                    onContinue: continueLesson == null
                        ? null
                        : () => _openLesson(context, continueLesson),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  category == LearningCategory.mixed
                      ? AppSpacing.sp24
                      : AppSpacing.sp16,
                  AppSpacing.sp4,
                  category == LearningCategory.mixed
                      ? AppSpacing.sp24
                      : AppSpacing.sp16,
                  AppSpacing.sp8,
                ),
                child: _PathSectionHeader(
                  title: category == LearningCategory.mixed
                      ? 'Lộ trình N$selectedLevel'
                      : '${categorySpec.sectionTitle} N$selectedLevel',
                  subtitle: category == LearningCategory.mixed
                      ? 'Đi từng chặng nhỏ, kiểm tra đúng lúc và mở khóa bài mới.'
                      : categorySpec.sectionSubtitle,
                ),
              ),
            ),
            if (levelLessons.isEmpty)
              AppEmptyState.sliver(
                icon: Icons.auto_stories_rounded,
                message: 'Chưa có bài học nào cho trình độ này.',
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  category == LearningCategory.mixed ? AppSpacing.sp24 : 0,
                  AppSpacing.sp20,
                  category == LearningCategory.mixed ? AppSpacing.sp24 : 0,
                  AppSpacing.sp48,
                ),
                sliver: category == LearningCategory.mixed
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final lesson = levelLessons[index];
                          return _MixedPathCard(
                            index: index,
                            total: levelLessons.length,
                            lesson: lesson,
                            onTap: lesson.isUnlocked
                                ? () => _openLesson(context, lesson)
                                : null,
                          );
                        }, childCount: levelLessons.length),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final lesson = levelLessons[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sp16,
                            ).copyWith(bottom: AppSpacing.sp12),
                            child: _FocusedLessonCard(
                              index: index,
                              total: levelLessons.length,
                              lesson: lesson,
                              spec: categorySpec,
                              onTap: lesson.isUnlocked
                                  ? () => _openLesson(context, lesson)
                                  : null,
                            ),
                          );
                        }, childCount: levelLessons.length),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LessonDetailScreen(lesson: lesson)),
    );
  }

  Lesson? _currentLesson(List<Lesson> lessons) {
    for (final lesson in lessons) {
      if (lesson.isUnlocked && !lesson.isCompleted) return lesson;
    }
    return lessons.isEmpty ? null : lessons.first;
  }
}

class _LearningPathAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(learningCategoryProvider);
    String title = 'Lộ trình học';
    switch (category) {
      case LearningCategory.mixed:
        title = 'Tổng hợp';
        break;
      case LearningCategory.vocabulary:
        title = 'Từ vựng';
        break;
      case LearningCategory.grammar:
        title = 'Ngữ pháp';
        break;
      case LearningCategory.kanji:
        title = 'Chữ Hán';
        break;
    }

    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.cream.withValues(alpha: 0.94),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTypography.headingM.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      actions: [
        if (category == LearningCategory.mixed)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp12),
            child: Tooltip(
              message: 'Kiểm tra năng lực',
              child: _PlacementAppBarButton(
                onTap: () {
                  if (!context.mounted ||
                      ModalRoute.of(context)?.isCurrent != true) {
                    return;
                  }
                  Navigator.push(context, AppRoutes.placementTest());
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _PlacementAppBarButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlacementAppBarButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp12),
          decoration: BoxDecoration(
            gradient: AppColors.brandLeafGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.72)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.fact_check_rounded,
                color: AppColors.white,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sp4),
              Text(
                'Đánh giá',
                style: AppTypography.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningOverviewCard extends StatelessWidget {
  final int level;
  final int completed;
  final int total;
  final Lesson? currentLesson;
  final VoidCallback? onContinue;

  const _LearningOverviewCard({
    required this.level,
    required this.completed,
    required this.total,
    required this.currentLesson,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final current = currentLesson;

    return AppCard(
      padding: EdgeInsets.zero,
      gradient: const LinearGradient(
        colors: [AppColors.navy, AppColors.terracotta, AppColors.leafGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: AppColors.navy.withValues(alpha: 0.16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Stack(
          children: [
            Positioned(
              right: -34,
              top: -30,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: 26,
              bottom: 18,
              child: Icon(
                Icons.hub_rounded,
                size: 72,
                color: AppColors.white.withValues(alpha: 0.08),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusM,
                          ),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng hợp N$level',
                              style: AppTypography.headingL.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              'Lộ trình trộn từ vựng, ngữ pháp và chữ Hán.',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.white.withValues(alpha: 0.76),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  Row(
                    children: [
                      _OverviewStat(value: '$completed/$total', label: 'chặng'),
                      const SizedBox(width: AppSpacing.sp8),
                      _OverviewStat(
                        value: '${(progress * 100).round()}%',
                        label: 'tiến độ',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.white.withValues(alpha: 0.16),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.leafLight,
                      ),
                    ),
                  ),
                  if (current != null) ...[
                    const SizedBox(height: AppSpacing.sp12),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sp8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.isCompleted
                                      ? 'Đã hoàn thành'
                                      : 'Học tiếp',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.68,
                                    ),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sp4),
                                Text(
                                  current.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMBold.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp12),
                          IconButton.filled(
                            onPressed: onContinue,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewStat({required this.value, required this.label});

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
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1.2,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelS.copyWith(
                color: AppColors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillMixStrip extends StatelessWidget {
  final int vocabCount;
  final int grammarCount;
  final int kanjiCount;

  const _SkillMixStrip({
    required this.vocabCount,
    required this.grammarCount,
    required this.kanjiCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SkillMiniCard(
          icon: Icons.menu_book_rounded,
          label: 'Từ',
          value: vocabCount,
          color: AppColors.waterBlue,
        ),
        const SizedBox(width: AppSpacing.sp8),
        _SkillMiniCard(
          icon: Icons.edit_note_rounded,
          label: 'Ngữ pháp',
          value: grammarCount,
          color: AppColors.leafGreen,
        ),
        const SizedBox(width: AppSpacing.sp8),
        _SkillMiniCard(
          icon: Icons.translate_rounded,
          label: 'Chữ Hán',
          value: kanjiCount,
          color: AppColors.navy,
        ),
      ],
    );
  }
}

class _SkillMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _SkillMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sp12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: AppSpacing.sp8),
            Text(
              '$value',
              style: AppTypography.bodyMBold.copyWith(
                color: AppColors.navyDark,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelS.copyWith(
                color: AppColors.slateMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusedLearningHero extends StatelessWidget {
  final _LearningCategorySpec spec;
  final int level;
  final int completed;
  final int total;
  final int itemCount;
  final Lesson? currentLesson;
  final VoidCallback? onContinue;

  const _FocusedLearningHero({
    required this.spec,
    required this.level,
    required this.completed,
    required this.total,
    required this.itemCount,
    required this.currentLesson,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final current = currentLesson;

    return AppCard(
      padding: EdgeInsets.zero,
      gradient: spec.gradient,
      shadowColor: spec.accent.withValues(alpha: 0.14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -34,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 14,
              child: Icon(
                spec.icon,
                size: 72,
                color: AppColors.white.withValues(alpha: 0.09),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sp16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusM,
                          ),
                        ),
                        child: Icon(
                          spec.icon,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${spec.heroTitle} N$level',
                              style: AppTypography.headingL.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              spec.heroSubtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.white.withValues(alpha: 0.76),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  Row(
                    children: [
                      _OverviewStat(value: '$completed/$total', label: 'bài'),
                      const SizedBox(width: AppSpacing.sp8),
                      _OverviewStat(value: '$itemCount', label: spec.itemUnit),
                      const SizedBox(width: AppSpacing.sp8),
                      _OverviewStat(
                        value: '${(progress * 100).round()}%',
                        label: 'tiến độ',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.white.withValues(alpha: 0.16),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.leafLight,
                      ),
                    ),
                  ),
                  if (current != null) ...[
                    const SizedBox(height: AppSpacing.sp12),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sp8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  current.isCompleted
                                      ? 'Đã hoàn thành'
                                      : 'Bài đang mở',
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.68,
                                    ),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sp4),
                                Text(
                                  current.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyMBold.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp12),
                          IconButton.filled(
                            onPressed: onContinue,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: spec.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FocusedLessonCard extends StatelessWidget {
  final int index;
  final int total;
  final Lesson lesson;
  final _LearningCategorySpec spec;
  final VoidCallback? onTap;

  const _FocusedLessonCard({
    required this.index,
    required this.total,
    required this.lesson,
    required this.spec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !lesson.isUnlocked;
    final isQuiz = lesson.type == LessonType.quiz;
    final accent = lesson.isCompleted
        ? AppColors.sunGold
        : isLocked
        ? AppColors.slateMuted
        : isQuiz
        ? AppColors.terracotta
        : spec.accent;
    final statusLabel = lesson.isCompleted
        ? 'Xong'
        : isLocked
        ? 'Khóa'
        : isQuiz
        ? 'Quiz'
        : 'Mở';

    return AppCard(
      onTap: onTap,
      color: isLocked
          ? AppColors.creamDark.withValues(alpha: 0.62)
          : AppColors.white,
      borderColor: accent.withValues(alpha: 0.16),
      shadowColor: AppColors.navy.withValues(alpha: isLocked ? 0 : 0.045),
      padding: const EdgeInsets.all(AppSpacing.sp16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isLocked ? 0.12 : 0.14),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Icon(_iconForState(isLocked, isQuiz), color: accent),
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
                        lesson.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headingS.copyWith(
                          color: isLocked
                              ? AppColors.slateMuted
                              : AppColors.navyDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp8),
                    _StatusBadge(label: statusLabel, color: accent),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  _description(isQuiz),
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.slateMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp12),
                Wrap(
                  spacing: AppSpacing.sp8,
                  runSpacing: AppSpacing.sp8,
                  children: [
                    _ContentChip(
                      icon: Icons.layers_rounded,
                      label: '${index + 1}/$total',
                      color: accent,
                    ),
                    if (lesson.vocabIds.isNotEmpty)
                      _ContentChip(
                        icon: Icons.menu_book_rounded,
                        label: '${lesson.vocabIds.length} từ',
                        color: AppColors.waterBlue,
                      ),
                    if (lesson.grammarIds.isNotEmpty)
                      _ContentChip(
                        icon: Icons.edit_note_rounded,
                        label: '${lesson.grammarIds.length} ngữ pháp',
                        color: AppColors.leafGreen,
                      ),
                    if (lesson.kanjiIds.isNotEmpty)
                      _ContentChip(
                        icon: Icons.translate_rounded,
                        label: '${lesson.kanjiIds.length} chữ',
                        color: AppColors.navy,
                      ),
                    if (isQuiz)
                      const _ContentChip(
                        icon: Icons.fact_check_rounded,
                        label: 'ôn tổng hợp',
                        color: AppColors.terracotta,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp8),
          Icon(
            isLocked ? Icons.lock_rounded : Icons.chevron_right_rounded,
            color: accent,
          ),
        ],
      ),
    );
  }

  IconData _iconForState(bool isLocked, bool isQuiz) {
    if (lesson.isCompleted) return Icons.check_rounded;
    if (isLocked) return Icons.lock_rounded;
    if (isQuiz) return Icons.assignment_rounded;
    return spec.icon;
  }

  String _description(bool isQuiz) {
    if (isQuiz) return 'Kiểm tra nhanh các nội dung vừa mở khóa.';
    return spec.lessonSubtitle;
  }
}

class _LearningCategorySpec {
  final String heroTitle;
  final String heroSubtitle;
  final String sectionTitle;
  final String sectionSubtitle;
  final String lessonSubtitle;
  final String itemUnit;
  final IconData icon;
  final Color accent;
  final Gradient gradient;

  const _LearningCategorySpec({
    required this.heroTitle,
    required this.heroSubtitle,
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.lessonSubtitle,
    required this.itemUnit,
    required this.icon,
    required this.accent,
    required this.gradient,
  });

  factory _LearningCategorySpec.from(LearningCategory category) {
    return switch (category) {
      LearningCategory.vocabulary => const _LearningCategorySpec(
        heroTitle: 'Bài mới từ vựng',
        heroSubtitle: 'Mở thêm từ mới theo cấp JLPT và đưa vào vòng ôn tập.',
        sectionTitle: 'Từ vựng mới',
        sectionSubtitle: 'Các bài học ngắn để thêm từ mới vào kho nhớ.',
        lessonSubtitle: 'Học từ, âm đọc và nghĩa trước khi ôn lại bằng SRS.',
        itemUnit: 'từ mới',
        icon: Icons.menu_book_rounded,
        accent: AppColors.waterBlue,
        gradient: LinearGradient(
          colors: [AppColors.waterBlue, AppColors.leafGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      LearningCategory.grammar => const _LearningCategorySpec(
        heroTitle: 'Bài mới ngữ pháp',
        heroSubtitle: 'Nắm mẫu câu, cấu trúc và ví dụ theo từng cấp JLPT.',
        sectionTitle: 'Ngữ pháp mới',
        sectionSubtitle: 'Mở từng mẫu câu, đọc giải thích rồi luyện nhận diện.',
        lessonSubtitle: 'Học mẫu câu, cách dùng và ví dụ trước phần kiểm tra.',
        itemUnit: 'mẫu',
        icon: Icons.edit_note_rounded,
        accent: AppColors.leafGreen,
        gradient: LinearGradient(
          colors: [AppColors.terracotta, AppColors.sunGold, AppColors.leafDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      LearningCategory.kanji => const _LearningCategorySpec(
        heroTitle: 'Bài mới chữ Hán',
        heroSubtitle: 'Mở thêm chữ, âm đọc và nghĩa để luyện nhận diện.',
        sectionTitle: 'Chữ Hán mới',
        sectionSubtitle: 'Các thẻ chữ được chia nhỏ để dễ ghi nhớ mỗi ngày.',
        lessonSubtitle: 'Học mặt chữ, âm đọc và nghĩa rồi luyện viết khi cần.',
        itemUnit: 'chữ',
        icon: Icons.translate_rounded,
        accent: AppColors.navy,
        gradient: LinearGradient(
          colors: [AppColors.navyDark, AppColors.navy, AppColors.slateGrey],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      LearningCategory.mixed => const _LearningCategorySpec(
        heroTitle: 'Bài mới tổng hợp',
        heroSubtitle: 'Trộn từ vựng, ngữ pháp và chữ Hán theo lộ trình.',
        sectionTitle: 'Bài tổng hợp',
        sectionSubtitle: 'Đi từng chặng nhỏ và kiểm tra đúng lúc.',
        lessonSubtitle: 'Một chặng học ngắn, trộn đủ kỹ năng chính.',
        itemUnit: 'mục',
        icon: Icons.hub_rounded,
        accent: AppColors.leafGreen,
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.terracotta, AppColors.leafGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    };
  }
}

class _PathSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PathSectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingM.copyWith(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          subtitle,
          style: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
        ),
      ],
    );
  }
}

class _MixedPathCard extends StatelessWidget {
  final int index;
  final int total;
  final Lesson lesson;
  final VoidCallback? onTap;

  const _MixedPathCard({
    required this.index,
    required this.total,
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !lesson.isUnlocked;
    final isQuiz = lesson.type == LessonType.quiz;
    final accent = lesson.isCompleted
        ? AppColors.sunGold
        : isLocked
        ? AppColors.slateMuted
        : isQuiz
        ? AppColors.terracotta
        : AppColors.leafGreen;
    final icon = lesson.isCompleted
        ? Icons.check_rounded
        : isLocked
        ? Icons.lock_rounded
        : isQuiz
        ? Icons.assignment_rounded
        : Icons.play_arrow_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: Icon(icon, color: AppColors.white, size: 20),
              ),
              if (index < total - 1)
                Container(
                  width: 3,
                  height: 92,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sp4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: AppCard(
              onTap: onTap,
              color: isLocked
                  ? AppColors.creamDark.withValues(alpha: 0.62)
                  : AppColors.white,
              borderColor: accent.withValues(alpha: 0.16),
              shadowColor: AppColors.navy.withValues(
                alpha: isLocked ? 0 : 0.05,
              ),
              padding: const EdgeInsets.all(AppSpacing.sp16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headingS.copyWith(
                            color: isLocked
                                ? AppColors.slateMuted
                                : AppColors.navyDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp8),
                      _StatusBadge(
                        label: lesson.isCompleted
                            ? 'Xong'
                            : isLocked
                            ? 'Khóa'
                            : isQuiz
                            ? 'Quiz'
                            : 'Học',
                        color: accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sp8),
                  Text(
                    isQuiz
                        ? 'Kiểm tra lại các chặng vừa học.'
                        : 'Một chặng học ngắn, trộn đủ kỹ năng chính.',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.slateMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  Wrap(
                    spacing: AppSpacing.sp8,
                    runSpacing: AppSpacing.sp8,
                    children: [
                      if (lesson.vocabIds.isNotEmpty)
                        _ContentChip(
                          icon: Icons.menu_book_rounded,
                          label: '${lesson.vocabIds.length} từ',
                          color: AppColors.waterBlue,
                        ),
                      if (lesson.grammarIds.isNotEmpty)
                        _ContentChip(
                          icon: Icons.edit_note_rounded,
                          label: '${lesson.grammarIds.length} ngữ pháp',
                          color: AppColors.leafGreen,
                        ),
                      if (lesson.kanjiIds.isNotEmpty)
                        _ContentChip(
                          icon: Icons.translate_rounded,
                          label: '${lesson.kanjiIds.length} chữ',
                          color: AppColors.navy,
                        ),
                      if (isQuiz)
                        const _ContentChip(
                          icon: Icons.fact_check_rounded,
                          label: 'ôn tổng hợp',
                          color: AppColors.terracotta,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        style: AppTypography.labelS.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ContentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ContentChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
