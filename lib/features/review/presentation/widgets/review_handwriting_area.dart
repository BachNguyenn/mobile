import 'package:flutter/material.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';

class ReviewHandwritingArea extends StatelessWidget {
  final GlobalKey<HandwritingCanvasState> canvasKey;
  final ValueChanged<List<List<HandwritingPoint>>> onDrawingChanged;
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.mossGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
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
