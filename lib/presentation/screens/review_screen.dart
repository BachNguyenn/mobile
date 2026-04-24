import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/kanji_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/handwriting_canvas.dart';
import '../../core/services/handwriting_service.dart';
import '../providers/kanji_library_provider.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<KanjiCard> cards;

  const ReviewScreen({super.key, required this.cards});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  List<List<Offset>> _currentStrokes = [];
  String? _recognizedText;
  final HandwritingService _handwritingService = HandwritingService();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  @override
  void dispose() {
    _handwritingService.dispose();
    super.dispose();
  }

  void _onDrawingChanged(List<List<Offset>> strokes) {
    _currentStrokes = strokes;
  }

  Future<void> _handleCheck() async {
    final text = await _handwritingService.recognize(_currentStrokes);
    setState(() {
      _recognizedText = text;
      _showAnswer = true;
    });
  }

  void _handleRating(int rating) {
    // Emit event to update SRS (future implementation)
    ref.read(emitKanjiStudyEventProvider)(widget.cards[_currentIndex].id, rating);

    if (_currentIndex < widget.cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
        _recognizedText = null;
        _currentStrokes = [];
      });
      _canvasKey.currentState?.clear();
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành bài ôn tập.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Không có thẻ nào để ôn tập')),
      );
    }

    final card = widget.cards[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: Text('Ôn tập (${_currentIndex + 1}/${widget.cards.length})', style: AppTypography.headingM),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        child: Column(
          children: [
            // Target Info
            Center(
              child: Column(
                children: [
                  Text(
                    card.meanings,
                    style: AppTypography.headingL.copyWith(color: AppColors.ink),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sp8),
                  Text(
                    '${card.onyomi} / ${card.kunyomi}',
                    style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.sp32),

            // Handwriting Area
            Expanded(
              child: Stack(
                children: [
                  Container(
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
                        key: _canvasKey,
                        onDrawingChanged: _onDrawingChanged,
                        onClear: () => _currentStrokes = [],
                      ),
                    ),
                  ),
                  if (_showAnswer)
                    Positioned.fill(
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.9),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                card.kanji,
                                style: TextStyle(
                                  fontSize: 120,
                                  fontFamily: 'Serif',
                                  color: (_recognizedText == card.kanji) ? AppColors.mossGreen : AppColors.terracotta,
                                ),
                              ),
                              if (_recognizedText != null)
                                Text(
                                  'Bạn viết: $_recognizedText',
                                  style: AppTypography.bodyM.copyWith(
                                    color: (_recognizedText == card.kanji) ? AppColors.mossGreen : AppColors.terracotta,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: AppColors.slateLight),
                      onPressed: () => _canvasKey.currentState?.clear(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sp32),

            // Actions
            if (!_showAnswer)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusM)),
                    elevation: 0,
                  ),
                  child: const Text('Kiểm tra & Xem đáp án', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            else
              Column(
                children: [
                  Text('Bạn thấy chữ này thế nào?', style: AppTypography.bodyS),
                  const SizedBox(height: AppSpacing.sp16),
                  Row(
                    children: [
                      _buildRatingButton('Quên', AppColors.terracotta, 1),
                      const SizedBox(width: 8),
                      _buildRatingButton('Khó', AppColors.sunGold, 2),
                      const SizedBox(width: 8),
                      _buildRatingButton('Tốt', AppColors.mossGreen, 3),
                      const SizedBox(width: 8),
                      _buildRatingButton('Dễ', AppColors.waterBlue, 4),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButton(String label, Color color, int rating) {
    return Expanded(
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: () => _handleRating(rating),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            elevation: 0,
            side: BorderSide(color: color.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusS)),
            padding: EdgeInsets.zero,
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}