import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/lesson.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/lesson_controller.dart';
import '../widgets/handwriting_canvas.dart';
import '../widgets/lesson/lesson_quiz_content.dart';
import '../widgets/lesson/lesson_bottom_bar.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonControllerProvider(widget.lesson));
    final controller = ref.read(lessonControllerProvider(widget.lesson).notifier);

    // Listen for finished state
    ref.listen(lessonControllerProvider(widget.lesson), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Chúc mừng! Bạn đã hoàn thành bài học.'),
            backgroundColor: AppColors.mossGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    if (state.questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.mossGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: state.progress,
            backgroundColor: AppColors.creamDark,
            valueColor: const AlwaysStoppedAnimation(AppColors.mossGreen),
            minHeight: 12,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sp24),
                child: LessonQuizContent(
                  state: state,
                  onSelectAnswer: controller.selectAnswer,
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
    );
  }
}