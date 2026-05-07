import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/providers/review_controller.dart';
import 'package:mobile/features/review/presentation/widgets/review_handwriting_area.dart';
import 'package:mobile/features/review/presentation/widgets/review_rating_buttons.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final List<ReviewItem> items;

  const ReviewScreen({super.key, required this.items});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final GlobalKey<HandwritingCanvasState> _canvasKey =
      GlobalKey<HandwritingCanvasState>();

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.cream.withValues(alpha: 0.94),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: const AppPageBackground(
          child: Center(child: Text('Không có mục nào để ôn tập')),
        ),
      );
    }

    final state = ref.watch(reviewControllerProvider(widget.items));
    final controller = ref.read(
      reviewControllerProvider(widget.items).notifier,
    );
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
          const SnackBar(
            content: Text('Chúc mừng! Bạn đã hoàn thành phiên ôn tập.'),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ôn tập (${state.currentIndex + 1}/${widget.items.length})',
          style: AppTypography.headingM,
        ),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.slateGrey,
      ),
      body: AppPageBackground(
        child: Padding(
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
                        onTypedAnswer: controller.setTypedAnswer,
                      ),
              ),
              const SizedBox(height: AppSpacing.sp24),
              if (!state.showAnswer)
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canSubmit(item, state)
                        ? () => controller.handleCheck()
                        : null,
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
                          : state.typedAnswer.trim().isNotEmpty
                              ? 'Kiểm tra'
                              : 'Xem đáp án',
                      style: AppTypography.bodyMBold.copyWith(
                        color: Colors.white,
                      ),
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
      ),
    );
  }

  bool _canSubmit(ReviewItem item, ReviewState state) {
    if (item.choices.isNotEmpty && state.selectedChoice == null) return false;
    return true;
  }
}

// ═══════════════════════════════════════════════════════════════
// Review Prompt — with TTS speaker button
// ═══════════════════════════════════════════════════════════════

class _ReviewPrompt extends ConsumerWidget {
  final ReviewItem item;

  const _ReviewPrompt({required this.item});

  bool get _showSpeaker =>
      item.type == ReviewItemType.vocabulary ||
      item.type == ReviewItemType.sentence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                item.prompt,
                style: item.type == ReviewItemType.kanji
                    ? AppTypography.headingL.copyWith(color: AppColors.ink)
                    : AppTypography.headingM.copyWith(color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
            ),
            if (_showSpeaker) ...[
              const SizedBox(width: AppSpacing.sp8),
              IconButton.filledTonal(
                tooltip: 'Phát âm',
                onPressed: () => _speak(ref, item.prompt),
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.waterBlue.withValues(alpha: 0.12),
                  foregroundColor: AppColors.waterBlue,
                ),
              ),
            ],
          ],
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

  Future<void> _speak(WidgetRef ref, String text) async {
    try {
      await ref.read(audioServiceProvider).speakJapanese(text);
    } catch (_) {
      // Silently fail if TTS not available
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// Kanji Review Body — Handwriting (unchanged)
// ═══════════════════════════════════════════════════════════════

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
                        color: isCorrect
                            ? AppColors.mossGreen
                            : AppColors.terracotta,
                      ),
                    ),
                    if (state.recognizedText != null)
                      Text(
                        'Bạn viết: ${state.recognizedText}',
                        style: AppTypography.bodyM.copyWith(
                          color: isCorrect
                              ? AppColors.mossGreen
                              : AppColors.terracotta,
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
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.slateLight,
            ),
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

// ═══════════════════════════════════════════════════════════════
// Knowledge Review Body — Multiple Choice / Flip Card / Typing
// ═══════════════════════════════════════════════════════════════

class _KnowledgeReviewBody extends StatelessWidget {
  final ReviewItem item;
  final ReviewState state;
  final ValueChanged<String> onSelectChoice;
  final ValueChanged<String> onTypedAnswer;

  const _KnowledgeReviewBody({
    required this.item,
    required this.state,
    required this.onSelectChoice,
    required this.onTypedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    // ── Show Answer State ──────────────────────────────────
    if (state.showAnswer) {
      return _AnswerReveal(item: item, state: state);
    }

    // ── Multiple Choice ───────────────────────────────────
    if (item.choices.isNotEmpty) {
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
                  color:
                      isSelected ? AppColors.mossGreen : AppColors.slateLight,
                ),
              ),
              child: Text(choice, style: AppTypography.bodyM),
            ),
          );
        },
      );
    }

    // ── Typing Input (Vocabulary free-recall) ──────────────
    if (item.type == ReviewItemType.vocabulary) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Gõ nghĩa của từ này:',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp16),
          TextField(
            onChanged: onTypedAnswer,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'Nhập đáp án...',
              prefixIcon: const Icon(
                Icons.keyboard_rounded,
                color: AppColors.waterBlue,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                borderSide: BorderSide(
                  color: AppColors.slateLight.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                borderSide: const BorderSide(
                  color: AppColors.waterBlue,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Flip Card (Grammar / Sentence free-recall) ────────
    return _FlipCard(item: item);
  }
}

// ═══════════════════════════════════════════════════════════════
// Flip Card — 3D flip animation for free-recall mode
// ═══════════════════════════════════════════════════════════════

class _FlipCard extends StatefulWidget {
  final ReviewItem item;

  const _FlipCard({required this.item});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _toggleFlip,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * pi;
            final isFront = _flipAnimation.value < 0.5;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: isFront
                  ? _buildFront()
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: AppColors.slateMuted.withValues(alpha: 0.4),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            'Chạm để xem gợi ý',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            'Tự nhớ đáp án rồi bấm "Xem đáp án" bên dưới.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp24),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(
          color: AppColors.mossGreen.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.mossGreen.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.item.grammar?.formation.isNotEmpty ?? false) ...[
            Text(
              widget.item.grammar!.formation,
              style: AppTypography.bodyMBold.copyWith(
                color: AppColors.mossGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sp12),
          ],
          Text(
            widget.item.subtitle ?? '',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            'Chạm lại để lật',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Answer Reveal — shown after checking (with TTS + error insight)
// ═══════════════════════════════════════════════════════════════

class _AnswerReveal extends ConsumerWidget {
  final ReviewItem item;
  final ReviewState state;

  const _AnswerReveal({required this.item, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isCorrect;
    if (state.typedAnswer.trim().isNotEmpty) {
      isCorrect = QuizAnswerNormalizer.isCorrect(
        state.typedAnswer,
        item.answer,
      );
    } else {
      isCorrect =
          state.selectedChoice == null || state.selectedChoice == item.answer;
    }

    final errorInsight = isCorrect
        ? null
        : _ReviewErrorAnalyzer.analyze(
            item: item,
            selectedChoice: state.selectedChoice ?? state.typedAnswer,
          );

    final showSpeaker = item.type == ReviewItemType.vocabulary ||
        item.type == ReviewItemType.sentence;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                  color:
                      isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                  size: 40,
                ),
                if (showSpeaker) ...[
                  const SizedBox(width: AppSpacing.sp12),
                  IconButton.filledTonal(
                    tooltip: 'Phát âm đáp án',
                    onPressed: () => _speak(ref),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          AppColors.waterBlue.withValues(alpha: 0.12),
                      foregroundColor: AppColors.waterBlue,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sp12),
            Text(
              item.answer,
              style: AppTypography.headingS.copyWith(color: AppColors.ink),
              textAlign: TextAlign.center,
            ),
            if (state.typedAnswer.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp8),
              Text(
                'Bạn gõ: ${state.typedAnswer}',
                style: AppTypography.bodyM.copyWith(
                  color: isCorrect ? AppColors.mossGreen : AppColors.terracotta,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (item.grammar?.formation.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.sp12),
              Text(
                item.grammar!.formation,
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.slateGrey,
                ),
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
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.slateGrey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _speak(WidgetRef ref) async {
    // For vocab: speak the word (prompt), for sentence: speak the sentence text
    final textToSpeak =
        item.type == ReviewItemType.vocabulary ? item.prompt : item.prompt;
    try {
      await ref.read(audioServiceProvider).speakJapanese(textToSpeak);
    } catch (_) {}
  }
}

// ═══════════════════════════════════════════════════════════════
// Error Analyzer (unchanged from original)
// ═══════════════════════════════════════════════════════════════

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
      if (formation.contains('は') ||
          formation.contains('が') ||
          formation.contains('を')) {
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
    return pickedMarker.isNotEmpty &&
        answerMarker.isNotEmpty &&
        pickedMarker.first != answerMarker.first;
  }

  static bool _isNearMeaning(String a, String b) {
    final x = a.toLowerCase();
    final y = b.toLowerCase();
    if (x == y) return true;
    final distance = _levenshtein(x, y);
    return distance <= 3 ||
        (x.split(' ').toSet().intersection(y.split(' ').toSet()).isNotEmpty);
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
