import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../handwriting_canvas.dart';

class ReviewHandwritingArea extends StatelessWidget {
  final GlobalKey<HandwritingCanvasState> canvasKey;
  final Function(List<List<Offset>>) onDrawingChanged;
  final VoidCallback onClear;

  const ReviewHandwritingArea({
    super.key,
    required this.canvasKey,
    required this.onDrawingChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: HandwritingCanvas(
          key: canvasKey,
          onDrawingChanged: onDrawingChanged,
          onClear: onClear,
        ),
      ),
    );
  }
}
