import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/domain/entities/lesson.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/learning/presentation/providers/lesson_controller.dart';
import 'package:mobile/features/learning/presentation/screens/lesson_result_screen.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';
import 'package:mobile/features/learning/presentation/widgets/lesson_quiz_content.dart';
import 'package:mobile/features/learning/presentation/widgets/lesson_bottom_bar.dart';

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
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LessonResultScreen(
              lesson: widget.lesson,
              correctAnswers: next.correctAnswers,
              totalQuestions: next.questions.length,
            ),
          ),
        );
        /*
          SnackBar(
            content: const Text('Chúc mừng! Bạn đã hoàn thành bài học.'),
          ),
        */
      }
    });

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(child: CircularProgressIndicator(color: AppColors.mossGreen)),
      );
    }

    if (state.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppColors.slateGrey,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.quiz_outlined,
                  color: AppColors.slateMuted,
                  size: 48,
                ),
                const SizedBox(height: AppSpacing.sp16),
                Text(
                  'Chưa có câu hỏi cho bài này',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sp8),
                Text(
                  'Hãy thử lại sau khi dữ liệu bài học được bổ sung.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.slateGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
