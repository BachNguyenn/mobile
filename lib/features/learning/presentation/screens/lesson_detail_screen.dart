import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/features/learning/application/controllers/lesson_controller.dart';
import 'package:mobile/features/learning/presentation/screens/lesson_result_screen.dart';
import 'package:mobile/features/learning/presentation/widgets/lesson_bottom_bar.dart';
import 'package:mobile/features/learning/presentation/widgets/lesson_quiz_content.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final GlobalKey<HandwritingCanvasState> _canvasKey =
      GlobalKey<HandwritingCanvasState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonControllerProvider(widget.lesson));
    final controller = ref.read(
      lessonControllerProvider(widget.lesson).notifier,
    );

    ref.listen(lessonControllerProvider(widget.lesson), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LessonResultScreen(
              lesson: widget.lesson,
              correctAnswers: next.correctAnswers,
              totalQuestions: next.questions.where((q) => q.isScored).length,
            ),
          ),
        );
      }
    });

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: AppPageBackground(
          child: AppLoadingIndicator(color: AppColors.leafGreen),
        ),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(),
        body: const AppPageBackground(
          child: AppEmptyState(
            icon: Icons.quiz_outlined,
            title: 'Chưa có câu hỏi cho bài này',
            message: 'Hãy thử lại sau khi dữ liệu bài học được bổ sung.',
          ),
        ),
      );
    }

    final spec = _LessonDetailSpec.fromLesson(widget.lesson);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: AppPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp16,
                  AppSpacing.sp8,
                  AppSpacing.sp16,
                  AppSpacing.sp12,
                ),
                child: _LessonProgressHeader(
                  lesson: widget.lesson,
                  state: state,
                  spec: spec,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    0,
                    AppSpacing.sp16,
                    AppSpacing.sp12,
                  ),
                  child: LessonQuizContent(
                    state: state,
                    onSelectAnswer: controller.selectAnswer,
                    onTypedAnswerChanged: controller.updateTypedAnswer,
                    onDrawingChanged: controller.onDrawingChanged,
                    onResetCanvas: controller.resetCanvas,
                    canvasKey: _canvasKey,
                  ),
                ),
              ),
              LessonBottomBar(
                state: state,
                onCheck: controller.checkAnswer,
                onNext: () {
                  controller.nextQuestion();
                  _canvasKey.currentState?.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cream.withValues(alpha: 0.94),
      foregroundColor: AppColors.slateGrey,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Text(
        'Bài mới',
        style: AppTypography.headingS.copyWith(color: AppColors.navyDark),
      ),
    );
  }
}

class _LessonProgressHeader extends StatelessWidget {
  final Lesson lesson;
  final LessonState state;
  final _LessonDetailSpec spec;

  const _LessonProgressHeader({
    required this.lesson,
    required this.state,
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    final total = state.questions.length;
    final current = total == 0 ? 0 : state.currentIndex + 1;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: spec.color.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.045),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child: Icon(spec.icon, color: spec.color, size: 22),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingS.copyWith(
                        color: AppColors.navyDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'JLPT N${lesson.level} • ${spec.label}',
                      style: AppTypography.label.copyWith(
                        color: AppColors.slateMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              _ProgressBadge(current: current, total: total, color: spec.color),
            ],
          ),
          const SizedBox(height: AppSpacing.sp16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 8,
              backgroundColor: AppColors.creamDark,
              valueColor: AlwaysStoppedAnimation<Color>(spec.color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int current;
  final int total;
  final Color color;

  const _ProgressBadge({
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        '$current/$total',
        style: AppTypography.label.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LessonDetailSpec {
  final String label;
  final IconData icon;
  final Color color;

  const _LessonDetailSpec({
    required this.label,
    required this.icon,
    required this.color,
  });

  factory _LessonDetailSpec.fromLesson(Lesson lesson) {
    if (lesson.grammarIds.isNotEmpty &&
        lesson.vocabIds.isEmpty &&
        lesson.kanjiIds.isEmpty) {
      return const _LessonDetailSpec(
        label: 'Ngữ pháp',
        icon: Icons.account_tree_rounded,
        color: AppColors.terracotta,
      );
    }
    if (lesson.kanjiIds.isNotEmpty &&
        lesson.vocabIds.isEmpty &&
        lesson.grammarIds.isEmpty) {
      return const _LessonDetailSpec(
        label: 'Chữ Hán',
        icon: Icons.brush_rounded,
        color: AppColors.leafGreen,
      );
    }
    if (lesson.vocabIds.isNotEmpty &&
        lesson.kanjiIds.isEmpty &&
        lesson.grammarIds.isEmpty) {
      return const _LessonDetailSpec(
        label: 'Từ vựng',
        icon: Icons.style_rounded,
        color: AppColors.waterBlue,
      );
    }
    return const _LessonDetailSpec(
      label: 'Tổng hợp',
      icon: Icons.auto_stories_rounded,
      color: AppColors.navy,
    );
  }
}
