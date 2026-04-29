import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/presentation/providers/lesson_controller.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';

class LessonQuizContent extends StatefulWidget {
  final LessonState state;
  final ValueChanged<String> onSelectAnswer;
  final ValueChanged<List<List<Offset>>> onDrawingChanged;
  final VoidCallback onResetCanvas;
  final GlobalKey<HandwritingCanvasState> canvasKey;

  const LessonQuizContent({
    super.key,
    required this.state,
    required this.onSelectAnswer,
    required this.onDrawingChanged,
    required this.onResetCanvas,
    required this.canvasKey,
  });

  @override
  State<LessonQuizContent> createState() => _LessonQuizContentState();
}

class _LessonQuizContentState extends State<LessonQuizContent> {
  bool _showHint = false;

  @override
  void didUpdateWidget(covariant LessonQuizContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentIndex != widget.state.currentIndex) {
      _showHint = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.state.questions[widget.state.currentIndex];

    switch (currentQ.inputMode) {
      case QuizInputMode.handwriting:
        return _buildHandwritingQuiz(currentQ);
      case QuizInputMode.study:
        return _buildGrammarStudy(currentQ);
      case QuizInputMode.multipleChoice:
        return _buildMultipleChoiceQuiz(currentQ);
    }
  }

  Widget _buildGrammarStudy(QuizQuestion question) {
    final grammar = (question.payload as GrammarQuizPayload).grammarPoint;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizHeader(
            title: 'Cấu trúc ngữ pháp',
            subtitle: 'Đọc ví dụ trước khi tiếp tục',
            question: question,
            showHint: _showHint,
            onToggleHint: _toggleHint,
          ),
          const SizedBox(height: AppSpacing.sp20),
          _SurfaceCard(
            child: Column(
              children: [
                Text(
                  grammar.title,
                  style: AppTypography.headingL.copyWith(color: AppColors.ink),
                  textAlign: TextAlign.center,
                ),
                if (grammar.formation.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp8),
                  Text(
                    grammar.formation,
                    style: AppTypography.bodyL.copyWith(
                      color: AppColors.mossGreen,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp20),
          _InfoBlock(
            title: 'Giải thích',
            body: grammar.longExplanation.isNotEmpty
                ? grammar.longExplanation
                : grammar.shortExplanation,
          ),
          if (grammar.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp20),
            Text(
              'Ví dụ',
              style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
            ),
            const SizedBox(height: AppSpacing.sp12),
            ...grammar.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
                child: _ExampleCard(example: example),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuiz(QuizQuestion question) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizHeader(
            title: _titleFor(question.type),
            subtitle: _subtitleFor(question.type),
            question: question,
            showHint: _showHint,
            onToggleHint: _toggleHint,
          ),
          const SizedBox(height: AppSpacing.sp24),
          _PromptCard(question: question),
          const SizedBox(height: AppSpacing.sp24),
          Column(
            children: question.options
                .map((option) => _OptionCard(
                      option: option,
                      question: question,
                      isSelected: widget.state.selectedAnswer == option,
                      isAnswerChecked: widget.state.isAnswerChecked,
                      onTap: () => widget.onSelectAnswer(option),
                    ))
                .toList(),
          ),
          if (widget.state.isAnswerChecked &&
              (question.explanation?.isNotEmpty ?? false)) ...[
            const SizedBox(height: AppSpacing.sp12),
            _FeedbackCard(
              isCorrect: widget.state.isCorrect,
              answer: question.answer,
              explanation: question.explanation!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHandwritingQuiz(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuizHeader(
          title: 'Viết chữ Hán',
          subtitle: 'Viết chữ phù hợp với nghĩa bên dưới',
          question: question,
          showHint: _showHint,
          onToggleHint: _toggleHint,
        ),
        const SizedBox(height: AppSpacing.sp16),
        _PromptCard(question: question, compact: true),
        const SizedBox(height: AppSpacing.sp16),
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  border: Border.all(
                    color: AppColors.slateLight.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  child: HandwritingCanvas(
                    key: widget.canvasKey,
                    onDrawingChanged: widget.onDrawingChanged,
                    onClear: widget.onResetCanvas,
                  ),
                ),
              ),
              if (widget.state.isAnswerChecked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            question.answer,
                            style: TextStyle(
                              fontSize: 116,
                              fontFamily: 'Serif',
                              color: widget.state.isCorrect
                                  ? AppColors.mossGreen
                                  : AppColors.terracotta,
                            ),
                          ),
                          if (widget.state.recognizedText != null) ...[
                            const SizedBox(height: AppSpacing.sp8),
                            Text(
                              'Bạn đã viết: ${widget.state.recognizedText}',
                              style: AppTypography.bodyM.copyWith(
                                color: widget.state.isCorrect
                                    ? AppColors.mossGreen
                                    : AppColors.terracotta,
                              ),
                            ),
                          ],
                          if (question.explanation?.isNotEmpty ?? false) ...[
                            const SizedBox(height: AppSpacing.sp8),
                            Text(
                              question.explanation!,
                              style: AppTypography.bodyS.copyWith(
                                color: AppColors.slateGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  tooltip: 'Xóa nét viết',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.slateLight,
                  ),
                  onPressed: () {
                    if (!widget.state.isAnswerChecked) {
                      widget.canvasKey.currentState?.clear();
                      widget.onResetCanvas();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toggleHint() {
    setState(() {
      _showHint = !_showHint;
    });
  }

  String _titleFor(QuizType type) {
    switch (type) {
      case QuizType.meaning:
        return 'Chọn nghĩa chữ Hán';
      case QuizType.kanji:
        return 'Chọn chữ Hán';
      case QuizType.kanjiReading:
        return 'Chọn cách đọc chữ Hán';
      case QuizType.vocabMeaning:
        return 'Chọn nghĩa từ vựng';
      case QuizType.vocabReading:
        return 'Chọn cách đọc từ vựng';
      case QuizType.vocabReverse:
        return 'Chọn từ tiếng Nhật';
      case QuizType.grammarMeaning:
        return 'Chọn ý nghĩa ngữ pháp';
      case QuizType.grammarFormation:
        return 'Chọn cấu trúc ngữ pháp';
      case QuizType.grammarUsage:
        return 'Chọn cấu trúc phù hợp';
      case QuizType.grammarStudy:
        return 'Cấu trúc ngữ pháp';
      case QuizType.handwriting:
        return 'Viết chữ Hán';
    }
  }

  String _subtitleFor(QuizType type) {
    switch (type) {
      case QuizType.vocabReverse:
        return 'Nhìn nghĩa và chọn từ đúng';
      case QuizType.grammarUsage:
        return 'Dựa vào ví dụ để chọn mẫu câu';
      case QuizType.kanjiReading:
        return 'Nhìn chữ và chọn cách đọc';
      default:
        return 'Chọn đáp án chính xác nhất';
    }
  }
}

class _QuizHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final QuizQuestion question;
  final bool showHint;
  final VoidCallback onToggleHint;

  const _QuizHeader({
    required this.title,
    required this.subtitle,
    required this.question,
    required this.showHint,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    final hasHint = question.hint?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headingM.copyWith(
                      color: AppColors.slateGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.slateMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (hasHint)
              IconButton.filledTonal(
                tooltip: showHint ? 'Ẩn gợi ý' : 'Xem gợi ý',
                onPressed: onToggleHint,
                icon: Icon(
                  showHint
                      ? Icons.lightbulb_rounded
                      : Icons.lightbulb_outline_rounded,
                ),
              ),
          ],
        ),
        if (hasHint && showHint) ...[
          const SizedBox(height: AppSpacing.sp12),
          _HintCard(text: question.hint!),
        ],
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  final QuizQuestion question;
  final bool compact;

  const _PromptCard({required this.question, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isJapaneseDisplay = switch (question.type) {
      QuizType.meaning ||
      QuizType.kanjiReading ||
      QuizType.vocabMeaning ||
      QuizType.vocabReading => true,
      _ => false,
    };

    return _SurfaceCard(
      child: Text(
        question.prompt,
        style: (isJapaneseDisplay
                ? AppTypography.kanjiHero
                : AppTypography.headingL)
            .copyWith(
          color: AppColors.ink,
          fontSize: isJapaneseDisplay ? (compact ? 40 : 56) : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String option;
  final QuizQuestion question;
  final bool isSelected;
  final bool isAnswerChecked;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.question,
    required this.isSelected,
    required this.isAnswerChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = option == question.answer;
    final showCorrect = isAnswerChecked && isCorrect;
    final showWrong = isAnswerChecked && isSelected && !isCorrect;

    final bgColor = showCorrect
        ? AppColors.mossGreen.withValues(alpha: 0.1)
        : showWrong
            ? AppColors.terracotta.withValues(alpha: 0.1)
            : isSelected
                ? AppColors.waterBlue.withValues(alpha: 0.1)
                : AppColors.white;
    final borderColor = showCorrect
        ? AppColors.mossGreen
        : showWrong
            ? AppColors.terracotta
            : isSelected
                ? AppColors.waterBlue
                : AppColors.slateLight.withValues(alpha: 0.6);
    final textColor = showCorrect
        ? AppColors.mossGreen
        : showWrong
            ? AppColors.terracotta
            : AppColors.slateGrey;

    final IconData? icon = showCorrect
        ? Icons.check_circle_rounded
        : showWrong
            ? Icons.cancel_rounded
            : isSelected
                ? Icons.radio_button_checked_rounded
                : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
      child: InkWell(
        onTap: isAnswerChecked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sp16,
            horizontal: AppSpacing.sp20,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: AppTypography.bodyL.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontFamily: _usesJapaneseFont(question.type)
                        ? 'Noto Sans JP'
                        : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sp12),
                Icon(icon, color: textColor, size: 22),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _usesJapaneseFont(QuizType type) {
    return type == QuizType.vocabReverse ||
        type == QuizType.kanji ||
        type == QuizType.kanjiReading;
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String answer;
  final String explanation;

  const _FeedbackCard({
    required this.isCorrect,
    required this.answer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.mossGreen : AppColors.terracotta;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCorrect ? 'Giải thích' : 'Đáp án đúng: $answer',
            style: AppTypography.bodyMBold.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            explanation,
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
        ],
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  final String text;

  const _HintCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        color: AppColors.sunGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: AppColors.sunGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates_rounded,
            color: AppColors.sunGold,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;

  const _InfoBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
        ),
        const SizedBox(height: AppSpacing.sp8),
        Text(
          body,
          style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final GrammarExample example;

  const _ExampleCard({required this.example});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.jp,
            style: AppTypography.bodyL.copyWith(
              color: AppColors.ink,
              fontFamily: 'Noto Sans JP',
              fontWeight: FontWeight.w600,
            ),
          ),
          if (example.romaji.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              example.romaji,
              style: AppTypography.labelS.copyWith(
                color: AppColors.slateMuted,
              ),
            ),
          ],
          if (example.en.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              example.en,
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
          ],
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
