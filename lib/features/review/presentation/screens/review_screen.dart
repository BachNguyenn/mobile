import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/providers/review_controller.dart';
import 'package:mobile/features/review/presentation/widgets/review_handwriting_area.dart';
import 'package:mobile/features/review/presentation/widgets/review_rating_buttons.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<ReviewItem> items;

  const ReviewScreen({super.key, required this.items});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Không có mục nào để ôn tập')),
      );
    }

    final state = ref.watch(reviewControllerProvider(widget.items));
    final controller = ref.read(reviewControllerProvider(widget.items).notifier);
    final item = widget.items[state.currentIndex];

    ref.listen(reviewControllerProvider(widget.items), (previous, next) {
      if (next.isFinished && !(previous?.isFinished ?? false)) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
        messenger?.showSnackBar(
          const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành phiên ôn tập.')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ôn tập (${state.currentIndex + 1}/${widget.items.length})',
          style: AppTypography.headingM,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ReviewPrompt(item: item),
            const SizedBox(height: AppSpacing.sp24),
            Expanded(
              child: item.usesHandwriting
                  ? _KanjiReviewBody(
                      item: item,
                      state: state,
                      controller: controller,
                      canvasKey: _canvasKey,
                    )
                  : _KnowledgeReviewBody(
                      item: item,
                      state: state,
                      onSelectChoice: controller.selectChoice,
                    ),
            ),
            const SizedBox(height: AppSpacing.sp24),
            if (!state.showAnswer)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: item.choices.isNotEmpty && state.selectedChoice == null
                      ? null
                      : () => controller.handleCheck(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mossGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.slateLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    item.usesHandwriting || item.choices.isNotEmpty
                        ? 'Kiểm tra & xem đáp án'
                        : 'Xem đáp án',
                    style: AppTypography.bodyMBold.copyWith(color: Colors.white),
                  ),
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

class _ReviewPrompt extends StatelessWidget {
  final ReviewItem item;

  const _ReviewPrompt({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          item.prompt,
          style: item.type == ReviewItemType.kanji
              ? AppTypography.headingL.copyWith(color: AppColors.ink)
              : AppTypography.headingM.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sp8),
          Text(
            item.subtitle!,
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.sp8),
        Text(
          'N${item.jlptLevel}',
          style: AppTypography.label.copyWith(color: AppColors.mossGreen),
        ),
      ],
    );
  }
}

class _KanjiReviewBody extends StatelessWidget {
  final ReviewItem item;
  final ReviewState state;
  final ReviewController controller;
  final GlobalKey<HandwritingCanvasState> canvasKey;

  const _KanjiReviewBody({
    required this.item,
    required this.state,
    required this.controller,
    required this.canvasKey,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = state.recognizedText == item.answer;
    return Stack(
      children: [
        ReviewHandwritingArea(
          canvasKey: canvasKey,
          onDrawingChanged: controller.onDrawingChanged,
          onClear: controller.resetCanvas,
        ),
        if (state.showAnswer)
          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(alpha: 0.92),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.answer,
                      style: TextStyle(
                        fontSize: 116,
                        fontFamily: 'Serif',
                        color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                      ),
                    ),
                    if (state.recognizedText != null)
                      Text(
                        'Bạn viết: ${state.recognizedText}',
                        style: AppTypography.bodyM.copyWith(
                          color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
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
            onPressed: () {
              canvasKey.currentState?.clear();
              controller.resetCanvas();
            },
          ),
        ),
      ],
    );
  }
}

class _KnowledgeReviewBody extends StatelessWidget {
  final ReviewItem item;
  final ReviewState state;
  final ValueChanged<String> onSelectChoice;

  const _KnowledgeReviewBody({
    required this.item,
    required this.state,
    required this.onSelectChoice,
  });

  @override
  Widget build(BuildContext context) {
    if (state.showAnswer) {
      final isCorrect = state.selectedChoice == null || state.selectedChoice == item.answer;
      final errorInsight = isCorrect
          ? null
          : _ReviewErrorAnalyzer.analyze(
              item: item,
              selectedChoice: state.selectedChoice,
            );
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sp20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: (isCorrect ? AppColors.mossGreen : AppColors.terracotta)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.sp12),
              Text(
                item.answer,
                style: AppTypography.headingS.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
              if (item.grammar?.formation.isNotEmpty ?? false) ...[
                const SizedBox(height: AppSpacing.sp12),
                Text(
                  item.grammar!.formation,
                  style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
                  textAlign: TextAlign.center,
                ),
              ],
              if (errorInsight != null) ...[
                const SizedBox(height: AppSpacing.sp12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sp12),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    border: Border.all(
                      color: AppColors.terracotta.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    errorInsight,
                    style: AppTypography.bodyS.copyWith(color: AppColors.slateGrey),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (item.choices.isEmpty) {
      return Center(
        child: Text(
          'Tự nhớ đáp án rồi bấm xem đáp án.',
          style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: item.choices.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sp12),
      itemBuilder: (context, index) {
        final choice = item.choices[index];
        final isSelected = state.selectedChoice == choice;
        return InkWell(
          onTap: () => onSelectChoice(choice),
          borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sp16),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.mossGreen.withValues(alpha: 0.12)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
              border: Border.all(
                color: isSelected ? AppColors.mossGreen : AppColors.slateLight,
              ),
            ),
            child: Text(choice, style: AppTypography.bodyM),
          ),
        );
      },
    );
  }
}

abstract final class _ReviewErrorAnalyzer {
  static String? analyze({
    required ReviewItem item,
    required String? selectedChoice,
  }) {
    final picked = selectedChoice?.trim();
    if (picked == null || picked.isEmpty) {
      return 'Bạn chưa chọn đáp án. Hãy thử tự trả lời trước rồi so sánh với đáp án đúng để nhớ lâu hơn.';
    }

    if (item.type == ReviewItemType.grammar) {
      final formation = item.grammar?.formation.toLowerCase() ?? '';
      if (formation.contains('は') || formation.contains('が') || formation.contains('を')) {
        return 'Bạn có thể đang nhầm trợ từ. Hãy kiểm tra vai trò chủ đề/chủ ngữ/tân ngữ trong câu mẫu.';
      }
      if (_looksLikeTenseConfusion(picked, item.answer)) {
        return 'Bạn có thể đang nhầm thì hoặc sắc thái thời gian (đã/đang/sẽ). Hãy đối chiếu lại ngữ cảnh câu.';
      }
      return 'Bạn đang nhầm cách dùng mẫu ngữ pháp. Hãy đọc lại ví dụ và chú ý điều kiện dùng mẫu.';
    }

    if (item.type == ReviewItemType.vocabulary) {
      if (_isNearMeaning(picked, item.answer)) {
        return 'Bạn chọn nghĩa gần đúng nhưng chưa chính xác. Đây là nhóm từ gần nghĩa, cần học theo ngữ cảnh câu.';
      }
      return 'Bạn đang nhầm nghĩa từ. Hãy ôn lại từ này trong cụm/câu thay vì học đơn lẻ.';
    }

    if (item.type == ReviewItemType.kanji) {
      return 'Bạn có thể nhầm chữ có hình dạng gần giống. Hãy tập trung vào bộ thủ và nét đặc trưng của ký tự.';
    }

    return null;
  }

  static bool _looksLikeTenseConfusion(String picked, String answer) {
    const tenseMarkers = ['đã', 'đang', 'sẽ', 'past', 'present', 'future'];
    final pickedLower = picked.toLowerCase();
    final answerLower = answer.toLowerCase();
    final pickedMarker = tenseMarkers.where(pickedLower.contains).toList();
    final answerMarker = tenseMarkers.where(answerLower.contains).toList();
    return pickedMarker.isNotEmpty && answerMarker.isNotEmpty && pickedMarker.first != answerMarker.first;
  }

  static bool _isNearMeaning(String a, String b) {
    final x = a.toLowerCase();
    final y = b.toLowerCase();
    if (x == y) return true;
    final distance = _levenshtein(x, y);
    return distance <= 3 || (x.split(' ').toSet().intersection(y.split(' ').toSet()).isNotEmpty);
  }

  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final prev = List<int>.generate(t.length + 1, (i) => i);
    final curr = List<int>.filled(t.length + 1, 0);

    for (var i = 1; i <= s.length; i++) {
      curr[0] = i;
      for (var j = 1; j <= t.length; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j <= t.length; j++) {
        prev[j] = curr[j];
      }
    }
    return prev[t.length];
  }
}
