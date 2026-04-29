import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/presentation/screens/lesson_detail_screen.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';

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

    final levelLessons = lessons; // Already filtered by level in provider

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          _LearningPathAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 12),
                _LevelSelector(),
                if (!widget.isNavBarMode) ...[
                  const SizedBox(height: 12),
                  _CategorySelector(),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
          if (levelLessons.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 48,
                      color: AppColors.slateLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có bài học nào cho trình độ này.',
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.slateMuted,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final lesson = levelLessons[index];
                  final previousLesson = index > 0
                      ? levelLessons[index - 1]
                      : null;

                  return _PathNode(
                    index: index,
                    lesson: lesson,
                    previousLesson: previousLesson,
                    hideCounts: widget.isNavBarMode,
                    onTap: lesson.isUnlocked
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LessonDetailScreen(lesson: lesson),
                              ),
                            );
                          }
                        : null,
                  );
                }, childCount: levelLessons.length),
              ),
            ),
        ],
      ),
    );
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
      backgroundColor: AppColors.cream,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: AppTypography.headingM.copyWith(color: AppColors.slateGrey),
      ),
    );
  }
}

class _CategorySelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(learningCategoryProvider);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _CategoryItem(
            label: 'Từ vựng',
            category: LearningCategory.vocabulary,
            isSelected: selectedCategory == LearningCategory.vocabulary,
          ),
          _CategoryItem(
            label: 'Ngữ pháp',
            category: LearningCategory.grammar,
            isSelected: selectedCategory == LearningCategory.grammar,
          ),
          _CategoryItem(
            label: 'Chữ Hán',
            category: LearningCategory.kanji,
            isSelected: selectedCategory == LearningCategory.kanji,
          ),
          _CategoryItem(
            label: 'Tổng hợp',
            category: LearningCategory.mixed,
            isSelected: selectedCategory == LearningCategory.mixed,
          ),
        ],
      ),
    );
  }
}

class _CategoryItem extends ConsumerWidget {
  final String label;
  final LearningCategory category;
  final bool isSelected;

  const _CategoryItem({
    required this.label,
    required this.category,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(learningCategoryProvider.notifier).state = category,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mossGreen.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.mossGreen
                : AppColors.slateLight.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodyS.copyWith(
              color: isSelected ? AppColors.mossGreen : AppColors.slateGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLevel = ref.watch(selectedLevelProvider);

    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          final level = 5 - index; // 5, 4, 3, 2, 1
          final isSelected = selectedLevel == level;

          return GestureDetector(
            onTap: () => ref.read(selectedLevelProvider.notifier).state = level,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.mossGreen
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateLight.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  'N$level',
                  style: AppTypography.bodyMBold.copyWith(
                    color: isSelected ? Colors.white : AppColors.slateGrey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  final int index;
  final Lesson lesson;
  final Lesson? previousLesson;
  final VoidCallback? onTap;
  final bool hideCounts;

  const _PathNode({
    required this.index,
    required this.lesson,
    this.previousLesson,
    this.onTap,
    this.hideCounts = false,
  });

  // Calculate horizontal offset based on a sine wave pattern
  double _calculateOffsetX(int index, double screenWidth) {
    final maxOffset = screenWidth * 0.25; // 25% to left or right
    // cycle: 0 -> right -> 0 -> left -> 0
    final sineValue = sin(index * pi / 3);
    return sineValue * maxOffset;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentOffset = _calculateOffsetX(index, screenWidth);
    final previousOffset = previousLesson != null
        ? _calculateOffsetX(index - 1, screenWidth)
        : 0.0;

    final isCurrentNode = lesson.isUnlocked && !lesson.isCompleted;
    final nodeSize = isCurrentNode ? 80.0 : 64.0;

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Path Painter
          if (previousLesson != null)
            Positioned.fill(
              child: CustomPaint(
                painter: _PathPainter(
                  startX: previousOffset,
                  endX: currentOffset,
                  isCompleted: previousLesson!.isCompleted,
                ),
              ),
            ),

          // Node Button
          Positioned(
            left: (screenWidth / 2) + currentOffset - (nodeSize / 2),
            child: GestureDetector(
              onTap: onTap,
              child: _buildNodeContent(isCurrentNode, nodeSize),
            ),
          ),

          // Lesson Title Tooltip
          Positioned(
            left: currentOffset > 0
                ? null
                : (screenWidth / 2) + currentOffset + (nodeSize / 2) + 16,
            right: currentOffset <= 0
                ? null
                : (screenWidth / 2) - currentOffset + (nodeSize / 2) + 16,
            child: _buildLessonTooltip(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonTooltip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: AppTypography.label.copyWith(
              color: AppColors.slateGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (lesson.type == LessonType.lesson && !hideCounts) ...[
            Text(
              '${lesson.kanjiIds.length} Chữ Hán, ${lesson.vocabIds.length} Từ vựng',
              style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
            ),
            Text(
              '${lesson.grammarIds.length} Ngữ pháp',
              style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
            ),
          ] else if (lesson.type == LessonType.quiz)
            Text(
              'Ôn tập kiến thức',
              style: AppTypography.labelS.copyWith(color: AppColors.slateMuted),
            ),
        ],
      ),
    );
  }

  Widget _buildNodeContent(bool isCurrentNode, double size) {
    Color nodeColor;
    IconData nodeIcon;

    if (lesson.isCompleted) {
      nodeColor = AppColors.sunGold;
      nodeIcon = lesson.type == LessonType.quiz
          ? Icons.emoji_events_rounded
          : Icons.star_rounded;
    } else if (lesson.isUnlocked) {
      nodeColor = lesson.type == LessonType.quiz
          ? AppColors.terracotta
          : AppColors.mossGreen;
      nodeIcon = lesson.type == LessonType.quiz
          ? Icons.assignment_rounded
          : Icons.play_arrow_rounded;
    } else {
      nodeColor = AppColors.slateLight;
      nodeIcon = Icons.lock_rounded;
    }

    Widget node = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: nodeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: nodeColor.withValues(alpha: 0.4),
            blurRadius: isCurrentNode ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          nodeIcon,
          color: Colors.white,
          size: isCurrentNode ? 40 : 32,
        ),
      ),
    );

    if (isCurrentNode) {
      // Adding a subtle pulse effect with simple tween
      node = TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.05),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: node,
      );
    }

    return node;
  }
}

class _PathPainter extends CustomPainter {
  final double startX;
  final double endX;
  final bool isCompleted;

  _PathPainter({
    required this.startX,
    required this.endX,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted
          ? AppColors.sunGold.withValues(alpha: 0.6)
          : AppColors.slateLight.withValues(alpha: 0.3)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final centerX = size.width / 2;
    // Y offsets relative to current node center (y = 60)
    final startPt = Offset(centerX + startX, -60);
    final endPt = Offset(centerX + endX, 60);

    path.moveTo(startPt.dx, startPt.dy);

    // Draw a cubic bezier curve to make it smooth
    path.cubicTo(
      startPt.dx,
      startPt.dy + 60,
      endPt.dx,
      endPt.dy - 60,
      endPt.dx,
      endPt.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) {
    return oldDelegate.startX != startX ||
        oldDelegate.endX != endX ||
        oldDelegate.isCompleted != isCompleted;
  }
}
