import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/handwriting_canvas.dart';
import '../widgets/review/review_target_info.dart';
import '../widgets/review/review_handwriting_area.dart';
import '../widgets/review/review_answer_overlay.dart';
import '../widgets/review/review_rating_buttons.dart';
import '../providers/review_controller.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<KanjiCard> cards;

  const ReviewScreen({super.key, required this.cards});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Không có thẻ nào để ôn tập')),
      );
    }

    final state = ref.watch(reviewControllerProvider(widget.cards));
    final controller = ref.read(reviewControllerProvider(widget.cards).notifier);

    // Listen for finished state
    ref.listen(reviewControllerProvider(widget.cards), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành bài ôn tập.')),
        );
      }
    });

    final card = widget.cards[state.currentIndex];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Ôn tập (${state.currentIndex + 1}/${widget.cards.length})', 
            style: AppTypography.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        child: Column(
          children: [
            ReviewTargetInfo(card: card),
            const SizedBox(height: AppSpacing.sp32),
            
            Expanded(
              child: Stack(
                children: [
                  ReviewHandwritingArea(
                    canvasKey: _canvasKey,
                    onDrawingChanged: controller.onDrawingChanged,
                    onClear: controller.resetCanvas,
                  ),
                  if (state.showAnswer)
                    ReviewAnswerOverlay(
                      card: card,
                      recognizedText: state.recognizedText,
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.slateLight),
                      onPressed: () {
                        _canvasKey.currentState?.clear();
                        controller.resetCanvas();
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp32),

            if (!state.showAnswer)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: controller.handleCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
                    elevation: 0,
                  ),
                  child: const Text('Kiểm tra & Xem đáp án', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            else
              ReviewRatingButtons(
                onRate: (rating) {
                  controller.handleRating(rating);
                  _canvasKey.currentState?.clear();
                },
              ),
          ],
        ),
      ),
    );
  }
}