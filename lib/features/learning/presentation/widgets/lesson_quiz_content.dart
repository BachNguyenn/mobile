import 'package:flutter/material.dart';
import 'package:mobile/core/services/handwriting_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/learning/domain/entities/quiz_question.dart';
import 'package:mobile/features/learning/presentation/providers/lesson_controller.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';

void _noopString(String _) {}

class LessonQuizContent extends StatefulWidget {
  final LessonState state;
  final ValueChanged<String> onSelectAnswer;
  final ValueChanged<String> onTypedAnswerChanged;
  final ValueChanged<List<List<HandwritingPoint>>> onDrawingChanged;
  final VoidCallback onResetCanvas;
  final GlobalKey<HandwritingCanvasState> canvasKey;

  const LessonQuizContent({
    super.key,
    required this.state,
    required this.onSelectAnswer,
    this.onTypedAnswerChanged = _noopString,
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
      case QuizInputMode.typing:
        return _buildTypingQuiz(currentQ);
      case QuizInputMode.multipleChoice:
        return _buildMultipleChoiceQuiz(currentQ);
    }
  }

  Widget _buildGrammarStudy(QuizQuestion question) {
    final grammar = (question.payload as GrammarQuizPayload).grammarPoint;
    final spec = _LessonVisualSpec.forType(question.type);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizHeader(
            title: 'Cấu trúc ngữ pháp',
            subtitle: 'Đọc nhịp dùng mẫu câu trước khi tiếp tục',
            question: question,
            showHint: _showHint,
            onToggleHint: _toggleHint,
          ),
          const SizedBox(height: AppSpacing.sp20),
          _SurfaceCard(
            accent: spec.accent,
            tint: spec.tint,
            child: Column(
              children: [
                _LessonPill(
                  icon: spec.icon,
                  label: 'N${grammar.jlptLevel} • ${spec.label}',
                  color: spec.accent,
                ),
                const SizedBox(height: AppSpacing.sp16),
                Text(
                  grammar.title,
                  style: AppTypography.headingL.copyWith(color: AppColors.ink),
                  textAlign: TextAlign.center,
                ),
                if (grammar.formation.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sp16),
                  _PatternPanel(text: grammar.formation, color: spec.accent),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sp20),
          _InfoBlock(
            title: 'Giải thích',
            icon: Icons.menu_book_rounded,
            color: spec.accent,
            body: grammar.longExplanation.isNotEmpty
                ? grammar.longExplanation
                : grammar.shortExplanation,
          ),
          if (grammar.examples.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp20),
            _SectionLabel(
              icon: Icons.format_quote_rounded,
              label: 'Ví dụ',
              color: spec.accent,
            ),
            const SizedBox(height: AppSpacing.sp12),
            ...grammar.examples.map(
              (example) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
                child: _ExampleCard(example: example, color: spec.accent),
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
            children: [
              for (var index = 0; index < question.options.length; index++)
                _OptionCard(
                  option: question.options[index],
                  optionIndex: index,
                  question: question,
                  isSelected:
                      widget.state.selectedAnswer == question.options[index],
                  isAnswerChecked: widget.state.isAnswerChecked,
                  onTap: () => widget.onSelectAnswer(question.options[index]),
                ),
            ],
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

  Widget _buildTypingQuiz(QuizQuestion question) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _QuizHeader(
            title: _titleFor(question.type),
            subtitle: 'Nhập đáp án rồi kiểm tra',
            question: question,
            showHint: _showHint,
            onToggleHint: _toggleHint,
          ),
          const SizedBox(height: AppSpacing.sp24),
          _PromptCard(question: question),
          const SizedBox(height: AppSpacing.sp24),
          TextField(
            enabled: !widget.state.isAnswerChecked,
            onChanged: widget.onTypedAnswerChanged,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'Nhập đáp án',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                borderSide: BorderSide(
                  color: AppColors.slateLight.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                borderSide: const BorderSide(color: AppColors.mossGreen),
              ),
            ),
            style: AppTypography.bodyL.copyWith(color: AppColors.ink),
          ),
          if (widget.state.isAnswerChecked) ...[
            const SizedBox(height: AppSpacing.sp12),
            _FeedbackCard(
              isCorrect: widget.state.isCorrect,
              answer: question.answer,
              explanation: question.explanation ?? '',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHandwritingQuiz(QuizQuestion question) {
    final spec = _LessonVisualSpec.forType(question.type);

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
                    color: spec.accent.withValues(alpha: 0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sp24,
                              ),
                              child: Text(
                                question.explanation!,
                                style: AppTypography.bodyS.copyWith(
                                  color: AppColors.slateGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                child: IconButton.filledTonal(
                  tooltip: 'Xóa nét viết',
                  icon: const Icon(Icons.refresh_rounded),
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
      case QuizType.vocabReading:
        return 'Tập trung vào âm đọc kana';
      case QuizType.grammarUsage:
        return 'Dựa vào ví dụ để chọn mẫu câu';
      case QuizType.grammarFormation:
        return 'Nhận diện cách ghép mẫu câu';
      case QuizType.kanjiReading:
        return 'Nhìn chữ và chọn cách đọc';
      default:
        return 'Chọn đáp án chính xác nhất';
    }
  }
}

class _LessonVisualSpec {
  final String label;
  final IconData icon;
  final Color accent;
  final Color tint;

  const _LessonVisualSpec({
    required this.label,
    required this.icon,
    required this.accent,
    required this.tint,
  });

  factory _LessonVisualSpec.forType(QuizType type) {
    return switch (type) {
      QuizType.vocabMeaning ||
      QuizType.vocabReading ||
      QuizType.vocabReverse => const _LessonVisualSpec(
        label: 'Từ vựng',
        icon: Icons.style_rounded,
        accent: AppColors.waterBlue,
        tint: Color(0xFFF0F7FC),
      ),
      QuizType.grammarStudy ||
      QuizType.grammarMeaning ||
      QuizType.grammarFormation ||
      QuizType.grammarUsage => const _LessonVisualSpec(
        label: 'Ngữ pháp',
        icon: Icons.account_tree_rounded,
        accent: AppColors.terracotta,
        tint: Color(0xFFFCF2EC),
      ),
      QuizType.handwriting ||
      QuizType.meaning ||
      QuizType.kanji ||
      QuizType.kanjiReading => const _LessonVisualSpec(
        label: 'Chữ Hán',
        icon: Icons.brush_rounded,
        accent: AppColors.mossGreen,
        tint: Color(0xFFF2F6EF),
      ),
    };
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
    final spec = _LessonVisualSpec.forType(question.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sp16),
          decoration: BoxDecoration(
            color: spec.tint,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: spec.accent.withValues(alpha: 0.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: spec.accent.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                ),
                child: Icon(spec.icon, color: spec.accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headingM.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodyS.copyWith(
                        color: AppColors.slateGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasHint) ...[
                const SizedBox(width: AppSpacing.sp8),
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
            ],
          ),
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
    final spec = _LessonVisualSpec.forType(question.type);
    final isJapaneseDisplay = switch (question.type) {
      QuizType.meaning ||
      QuizType.kanjiReading ||
      QuizType.vocabMeaning ||
      QuizType.vocabReading => true,
      _ => false,
    };

    return _SurfaceCard(
      accent: spec.accent,
      tint: spec.tint,
      child: Column(
        children: [
          _PromptMetadata(question: question, spec: spec),
          const SizedBox(height: AppSpacing.sp16),
          Text(
            question.prompt,
            style:
                (isJapaneseDisplay
                        ? AppTypography.kanjiHero
                        : AppTypography.headingL)
                    .copyWith(
                      color: AppColors.ink,
                      fontSize: isJapaneseDisplay ? (compact ? 40 : 56) : null,
                    ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PromptMetadata extends StatelessWidget {
  final QuizQuestion question;
  final _LessonVisualSpec spec;

  const _PromptMetadata({required this.question, required this.spec});

  @override
  Widget build(BuildContext context) {
    final payload = question.payload;
    final chips = <String>[spec.label];

    if (payload is VocabularyQuizPayload) {
      chips.add('N${payload.vocabulary.jlptLevel}');
      if (question.type == QuizType.vocabMeaning &&
          payload.vocabulary.reading.isNotEmpty) {
        chips.add(payload.vocabulary.reading);
      }
    } else if (payload is KanjiQuizPayload) {
      chips.add('N${payload.card.jlptLevel}');
    } else if (payload is GrammarQuizPayload) {
      chips.add('N${payload.grammarPoint.jlptLevel}');
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sp8,
      runSpacing: AppSpacing.sp8,
      children: [
        for (final chip in chips)
          _LessonPill(icon: spec.icon, label: chip, color: spec.accent),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String option;
  final int optionIndex;
  final QuizQuestion question;
  final bool isSelected;
  final bool isAnswerChecked;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.optionIndex,
    required this.question,
    required this.isSelected,
    required this.isAnswerChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _LessonVisualSpec.forType(question.type);
    final isCorrect = option == question.answer;
    final showCorrect = isAnswerChecked && isCorrect;
    final showWrong = isAnswerChecked && isSelected && !isCorrect;

    final stateColor = showCorrect
        ? AppColors.mossGreen
        : showWrong
        ? AppColors.terracotta
        : isSelected
        ? spec.accent
        : AppColors.slateMuted;
    final bgColor = showCorrect || showWrong || isSelected
        ? stateColor.withValues(alpha: 0.1)
        : AppColors.white;
    final borderColor = showCorrect || showWrong || isSelected
        ? stateColor
        : AppColors.slateLight.withValues(alpha: 0.55);

    final IconData? trailingIcon = showCorrect
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
            vertical: AppSpacing.sp12,
            horizontal: AppSpacing.sp16,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (isSelected || showCorrect || showWrong)
                BoxShadow(
                  color: stateColor.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
            ],
          ),
          child: Row(
            children: [
              _OptionIndexBadge(
                label: String.fromCharCode(65 + optionIndex),
                color: stateColor,
                isActive: isSelected || showCorrect || showWrong,
              ),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Text(
                  option,
                  style: AppTypography.bodyL.copyWith(
                    color: showCorrect || showWrong
                        ? stateColor
                        : AppColors.slateGrey,
                    fontWeight: FontWeight.w700,
                    fontFamily: _usesJapaneseFont(question.type)
                        ? 'Noto Sans JP'
                        : null,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sp12),
                Icon(trailingIcon, color: stateColor, size: 22),
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

class _OptionIndexBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;

  const _OptionIndexBadge({
    required this.label,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      ),
      child: Text(
        label,
        style: AppTypography.bodyMBold.copyWith(
          color: isActive ? AppColors.white : color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.task_alt_rounded : Icons.info_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
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
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.slateGrey,
                  ),
                ),
              ],
            ),
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
  final IconData icon;
  final Color color;

  const _InfoBlock({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();

    return _SurfaceCard(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(icon: icon, label: title, color: color),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            body,
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final GrammarExample example;
  final Color color;

  const _ExampleCard({required this.example, required this.color});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      accent: color,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 74,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
            ),
          ),
          const SizedBox(width: AppSpacing.sp16),
          Expanded(
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
                    style: AppTypography.bodyM.copyWith(
                      color: AppColors.slateGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPanel extends StatelessWidget {
  final String text;
  final Color color;

  const _PatternPanel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sp12,
        horizontal: AppSpacing.sp16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: AppTypography.bodyL.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _LessonPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LessonPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sp8),
        Text(
          label,
          style: AppTypography.bodyMBold.copyWith(
            color: AppColors.slateGrey,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final Color? tint;

  const _SurfaceCard({required this.child, this.accent, this.tint});

  @override
  Widget build(BuildContext context) {
    final borderColor = accent ?? AppColors.slateLight;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: BoxDecoration(
        color: tint ?? AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: borderColor.withValues(alpha: 0.18)),
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
