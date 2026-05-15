import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/presentation/providers/sentence_provider.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_selector.dart';

enum SentencePracticeMode { readToMeaning, meaningToJapanese, typing }

const sentenceModeTypingKey = Key('sentence.mode.typing');
const sentenceCheckButtonKey = Key('sentence.check.button');
const sentenceCorrectFeedbackKey = Key('sentence.feedback.correct');

class SentencePracticeScreen extends ConsumerStatefulWidget {
  final Sentence? initialSentence;

  const SentencePracticeScreen({super.key, this.initialSentence});

  @override
  ConsumerState<SentencePracticeScreen> createState() =>
      _SentencePracticeScreenState();
}

class _SentencePracticeScreenState extends ConsumerState<SentencePracticeScreen> {
  SentencePracticeMode _mode = SentencePracticeMode.readToMeaning;
  int _currentIndex = 0;
  String? _selectedAnswer;
  String _typedAnswer = '';
  bool _isChecked = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(dueSentencePracticeProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Luyện câu',
          style: AppTypography.headingS.copyWith(color: AppColors.navyDark),
        ),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.slateGrey,
        elevation: 0,
      ),
      body: AppPageBackground(
        child: sentencesAsync.when(
          data: (sentences) {
            final allSentences = _prioritizeInitial(sentences);
            if (allSentences.isEmpty) {
              return const AppEmptyState(
                icon: Icons.subject_rounded,
                title: 'Chưa có câu ví dụ',
                message: 'Hãy quay lại sau khi dữ liệu câu được bổ sung.',
              );
            }

            final sentence = allSentences[_currentIndex % allSentences.length];
            return Column(
              children: [
                const SizedBox(height: AppSpacing.sp12),
                JlptLevelSelector(
                  selectedLevel: ref.watch(sentenceLevelFilterProvider),
                  accentColor: AppColors.terracotta,
                  onChanged: (level) {
                    ref.read(sentenceLevelFilterProvider.notifier).state =
                        level;
                    _resetSession();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    AppSpacing.sp12,
                    AppSpacing.sp16,
                    AppSpacing.sp8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeSelector(
                          mode: _mode,
                          onChanged: (mode) {
                            setState(() {
                              _mode = mode;
                              _resetQuestion();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp16),
                      _ProgressBadge(
                        current: _currentIndex + 1,
                        total: allSentences.length,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.sp16),
                    child: _PracticeCard(
                      sentence: sentence,
                      mode: _mode,
                      allSentences: allSentences,
                      selectedAnswer: _selectedAnswer,
                      typedAnswer: _typedAnswer,
                      isChecked: _isChecked,
                      isCorrect: _isCorrect,
                      onSelect: (answer) {
                        if (_isChecked) return;
                        setState(() => _selectedAnswer = answer);
                      },
                      onTyped: (answer) {
                        if (_isChecked) return;
                        setState(() => _typedAnswer = answer);
                      },
                      onSpeak: _speak,
                    ),
                  ),
                ),
                _BottomBar(
                  canCheck: _canCheck,
                  isChecked: _isChecked,
                  isCorrect: _isCorrect,
                  onCheck: () => _check(sentence),
                  onNext: () {
                    setState(() {
                      _currentIndex++;
                      _resetQuestion();
                    });
                  },
                ),
              ],
            );
          },
          loading: () =>
              const AppLoadingIndicator(color: AppColors.terracotta),
          error: (error, _) => AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tải câu',
            message: '$error',
          ),
        ),
      ),
    );
  }

  List<Sentence> _prioritizeInitial(List<Sentence> sentences) {
    final initial = widget.initialSentence;
    if (initial == null) return sentences;
    return [
      initial,
      ...sentences.where((sentence) => sentence.id != initial.id),
    ];
  }

  bool get _canCheck {
    return switch (_mode) {
      SentencePracticeMode.typing => _typedAnswer.trim().isNotEmpty,
      _ => _selectedAnswer != null,
    };
  }

  void _check(Sentence sentence) {
    final expected =
        _mode == SentencePracticeMode.meaningToJapanese ||
            _mode == SentencePracticeMode.typing
        ? sentence.text
        : sentence.meaning;
    final actual = _mode == SentencePracticeMode.typing
        ? _typedAnswer
        : _selectedAnswer ?? '';

    setState(() {
      _isCorrect = QuizAnswerNormalizer.isCorrect(actual, expected);
      _isChecked = true;
    });
  }

  void _resetSession() {
    setState(() {
      _currentIndex = 0;
      _resetQuestion();
    });
  }

  void _resetQuestion() {
    _selectedAnswer = null;
    _typedAnswer = '';
    _isChecked = false;
    _isCorrect = false;
  }

  Future<void> _speak(String text) async {
    try {
      await ref.read(audioServiceProvider).speakJapanese(text);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể phát âm thanh trên thiết bị này.'),
        ),
      );
    }
  }
}

class _PracticeCard extends StatelessWidget {
  final Sentence sentence;
  final SentencePracticeMode mode;
  final List<Sentence> allSentences;
  final String? selectedAnswer;
  final String typedAnswer;
  final bool isChecked;
  final bool isCorrect;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onTyped;
  final ValueChanged<String> onSpeak;

  const _PracticeCard({
    required this.sentence,
    required this.mode,
    required this.allSentences,
    required this.selectedAnswer,
    required this.typedAnswer,
    required this.isChecked,
    required this.isCorrect,
    required this.onSelect,
    required this.onTyped,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final prompt = switch (mode) {
      SentencePracticeMode.readToMeaning => sentence.text,
      SentencePracticeMode.meaningToJapanese => sentence.meaning,
      SentencePracticeMode.typing => sentence.meaning,
    };
    final answer = switch (mode) {
      SentencePracticeMode.readToMeaning => sentence.meaning,
      SentencePracticeMode.meaningToJapanese => sentence.text,
      SentencePracticeMode.typing => sentence.text,
    };
    final showSpeaker = mode == SentencePracticeMode.readToMeaning;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          color: AppColors.white,
          borderColor: AppColors.terracotta.withValues(alpha: 0.16),
          shadowColor: AppColors.terracotta.withValues(alpha: 0.04),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sp8,
                runSpacing: AppSpacing.sp8,
                children: [
                  _Pill(label: 'N${sentence.jlptLevel}'),
                  if (sentence.sourceGrammarTitle?.isNotEmpty ?? false)
                    _Pill(label: sentence.sourceGrammarTitle!),
                ],
              ),
              const SizedBox(height: AppSpacing.sp16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      prompt,
                      style:
                          (mode == SentencePracticeMode.readToMeaning
                                  ? AppTypography.headingL
                                  : AppTypography.headingM)
                              .copyWith(color: AppColors.ink),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (showSpeaker) ...[
                    const SizedBox(width: AppSpacing.sp8),
                    IconButton.filledTonal(
                      tooltip: 'Phát âm',
                      onPressed: () => onSpeak(sentence.text),
                      icon: const Icon(Icons.volume_up_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.terracotta.withValues(
                          alpha: 0.10,
                        ),
                        foregroundColor: AppColors.terracotta,
                      ),
                    ),
                  ],
                ],
              ),
              if (sentence.reading.isNotEmpty &&
                  mode == SentencePracticeMode.readToMeaning) ...[
                const SizedBox(height: AppSpacing.sp8),
                Text(
                  sentence.reading,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.slateMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sp20),
        if (mode == SentencePracticeMode.typing)
          TextField(
            enabled: !isChecked,
            onChanged: onTyped,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              hintText: 'Nhập câu tiếng Nhật...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              ),
            ),
          )
        else
          ..._options(answer).map(
            (option) => _OptionTile(
              option: option,
              selected: selectedAnswer == option,
              correct: isChecked && option == answer,
              wrong: isChecked && selectedAnswer == option && option != answer,
              onTap: () => onSelect(option),
            ),
          ),
        if (isChecked) ...[
          const SizedBox(height: AppSpacing.sp16),
          _AnswerCard(
            isCorrect: isCorrect,
            answer: answer,
            sentence: sentence,
            onSpeak: () => onSpeak(sentence.text),
          ),
        ],
      ],
    );
  }

  List<String> _options(String answer) {
    final pool = mode == SentencePracticeMode.meaningToJapanese
        ? allSentences.map((sentence) => sentence.text).toList()
        : allSentences.map((sentence) => sentence.meaning).toList();
    pool.shuffle();
    final distractors = pool
        .where((option) => option.isNotEmpty && option != answer)
        .toSet()
        .take(3)
        .toList();
    return ([...distractors, answer]..shuffle());
  }
}

class _ModeSelector extends StatelessWidget {
  final SentencePracticeMode mode;
  final ValueChanged<SentencePracticeMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SentencePracticeMode>(
      segments: const [
        ButtonSegment(
          value: SentencePracticeMode.readToMeaning,
          icon: Icon(Icons.translate_rounded),
          label: Text('Nghĩa'),
        ),
        ButtonSegment(
          value: SentencePracticeMode.meaningToJapanese,
          icon: Icon(Icons.subject_rounded),
          label: Text('Câu'),
        ),
        ButtonSegment(
          value: SentencePracticeMode.typing,
          icon: Icon(Icons.keyboard_rounded),
          label: Text('Gõ', key: sentenceModeTypingKey),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = correct
        ? AppColors.leafGreen
        : wrong
        ? AppColors.terracotta
        : selected
        ? AppColors.waterBlue
        : AppColors.slateLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sp16),
          decoration: BoxDecoration(
            color: selected || correct || wrong
                ? color.withValues(alpha: 0.10)
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: color.withValues(alpha: 0.7)),
          ),
          child: Text(
            option,
            style: AppTypography.bodyM.copyWith(color: AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final bool isCorrect;
  final String answer;
  final Sentence sentence;
  final VoidCallback onSpeak;

  const _AnswerCard({
    required this.isCorrect,
    required this.answer,
    required this.sentence,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.leafGreen : AppColors.terracotta;
    return AppCard(
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.22),
      shadowColor: color.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: color,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Expanded(
                child: Text(
                  isCorrect ? 'Chính xác' : 'Đáp án đúng',
                  key: isCorrect ? sentenceCorrectFeedbackKey : null,
                  style: AppTypography.bodyMBold.copyWith(color: color),
                ),
              ),
              IconButton(
                tooltip: 'Phát âm',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            answer,
            style: AppTypography.bodyL.copyWith(color: AppColors.ink),
          ),
          if (sentence.meaning != answer) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              sentence.meaning,
              style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        style: AppTypography.labelS.copyWith(color: AppColors.terracotta),
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        '$current/$total',
        style: AppTypography.label.copyWith(
          color: AppColors.terracotta,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool canCheck;
  final bool isChecked;
  final bool isCorrect;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const _BottomBar({
    required this.canCheck,
    required this.isChecked,
    required this.isCorrect,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.leafGreen : AppColors.terracotta;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.sp16,
          AppSpacing.sp12,
          AppSpacing.sp16,
          AppSpacing.sp16,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.96),
          border: Border(
            top: BorderSide(
              color: AppColors.slateLight.withValues(alpha: 0.32),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            key: sentenceCheckButtonKey,
            onPressed: isChecked ? onNext : (canCheck ? onCheck : null),
            style: FilledButton.styleFrom(
              backgroundColor: isChecked ? color : AppColors.terracotta,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.slateLight,
              disabledForegroundColor: AppColors.white.withValues(alpha: 0.74),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              ),
            ),
            child: Text(
              isChecked ? 'Tiếp tục' : 'Kiểm tra',
              style: AppTypography.bodyMBold.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
