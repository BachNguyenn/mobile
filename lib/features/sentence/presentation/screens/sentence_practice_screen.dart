import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/review/application/providers/study_event_provider.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/application/providers/sentence_provider.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_selector.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

enum SentencePracticeMode { readToMeaning, meaningToJapanese, typing }

const sentenceModeTypingKey = Key('sentence.mode.typing');
const sentenceCheckButtonKey = Key('sentence.check.button');
const sentenceCorrectFeedbackKey = Key('sentence.feedback.correct');
const sentenceHintButtonKey = Key('sentence.hint.button');
const sentenceSessionSummaryKey = Key('sentence.session.summary');
const sentenceCompletionKey = Key('sentence.session.complete');

Key _sentenceOptionKey(String option) => Key('sentenceOption:$option');

const int _targetSessionLength = 10;

class SentencePracticeScreen extends ConsumerStatefulWidget {
  final Sentence? initialSentence;

  const SentencePracticeScreen({super.key, this.initialSentence});

  @override
  ConsumerState<SentencePracticeScreen> createState() =>
      _SentencePracticeScreenState();
}

class _SentencePracticeScreenState
    extends ConsumerState<SentencePracticeScreen> {
  SentencePracticeMode _mode = SentencePracticeMode.readToMeaning;
  int _currentIndex = 0;
  final List<Sentence> _sessionQueue = [];
  String _sessionSignature = '';
  String? _optionsKey;
  List<String> _currentOptions = const [];
  String? _selectedAnswer;
  String _typedAnswer = '';
  bool _isChecked = false;
  bool _isCorrect = false;
  bool _showHint = false;
  int _completedCount = 0;
  int _correctCount = 0;
  int _retryCount = 0;
  int _streak = 0;

  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final sentencesAsync = ref.watch(dueSentencePracticeProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(_progress),
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

            _syncSession(allSentences);
            final hasFinished = _currentIndex >= _sessionQueue.length;
            final sentence = hasFinished ? null : _sessionQueue[_currentIndex];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final p = _sessionQueue.isEmpty
                  ? 0.0
                  : (_completedCount / _sessionQueue.length).clamp(0.0, 1.0);
              if (p != _progress) setState(() => _progress = p);
            });

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp16,
                  AppSpacing.sp4,
                  AppSpacing.sp16,
                  AppSpacing.sp12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: JlptLevelSelector(
                              selectedLevel: ref.watch(
                                sentenceLevelFilterProvider,
                              ),
                              accentColor: AppColors.terracotta,
                              onChanged: (level) {
                                ref
                                        .read(
                                          sentenceLevelFilterProvider.notifier,
                                        )
                                        .state =
                                    level;
                                _resetSession();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Row(
                      children: [
                        Expanded(
                          child: _SentenceModePills(
                            mode: _mode,
                            onChanged: (mode) {
                              setState(() {
                                _mode = mode;
                                _resetQuestion();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sp12),
                        _SentenceHeader(
                          current: hasFinished
                              ? _sessionQueue.length
                              : _currentIndex + 1,
                          total: _sessionQueue.length,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Expanded(
                      child: hasFinished
                          ? _SentenceSessionComplete(
                              completedCount: _completedCount,
                              correctCount: _correctCount,
                              retryCount: _retryCount,
                              onRestart: _restartSession,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SentenceSessionSummary(
                                  completedCount: _completedCount,
                                  totalCount: _sessionQueue.length,
                                  correctCount: _correctCount,
                                  retryCount: _retryCount,
                                  streak: _streak,
                                ),
                                const SizedBox(height: 6),
                                _SentencePromptCard(
                                  sentence: sentence!,
                                  mode: _mode,
                                  onSpeak: _speak,
                                ),
                                const SizedBox(height: 6),
                                if (!_isChecked) ...[
                                  _SentenceLearningAid(
                                    sentence: sentence,
                                    mode: _mode,
                                    showHint: _showHint,
                                    onToggleHint: () {
                                      setState(() => _showHint = !_showHint);
                                    },
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Expanded(
                                  child: _isChecked
                                      ? _SentenceAnswerPanel(
                                          sentence: sentence,
                                          mode: _mode,
                                          isCorrect: _isCorrect,
                                          selectedAnswer: _selectedAnswer,
                                          typedAnswer: _typedAnswer,
                                          wasHintUsed: _showHint,
                                          willRetry: !_isCorrect,
                                          onSpeak: () => _speak(sentence.text),
                                        )
                                      : _mode == SentencePracticeMode.typing
                                      ? Align(
                                          alignment: Alignment.topCenter,
                                          child: _TypingInput(
                                            enabled: !_isChecked,
                                            onChanged: (v) {
                                              if (_isChecked) return;
                                              setState(() => _typedAnswer = v);
                                            },
                                          ),
                                        )
                                      : _SentenceOptionList(
                                          sentence: sentence,
                                          mode: _mode,
                                          options: _optionsFor(
                                            sentence,
                                            allSentences,
                                          ),
                                          selectedAnswer: _selectedAnswer,
                                          isChecked: _isChecked,
                                          onSelect: (answer) {
                                            if (_isChecked) return;
                                            setState(
                                              () => _selectedAnswer = answer,
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    if (hasFinished)
                      PrimaryButton(
                        icon: Icons.refresh_rounded,
                        color: AppColors.terracotta,
                        label: 'Luyện phiên mới',
                        onPressed: _restartSession,
                      )
                    else if (!_isChecked)
                      PrimaryButton(
                        key: sentenceCheckButtonKey,
                        icon: Icons.fact_check_rounded,
                        color: AppColors.terracotta,
                        label: 'Kiểm tra',
                        onPressed: _canCheck ? () => _check(sentence!) : null,
                      )
                    else
                      PrimaryButton(
                        icon: Icons.arrow_forward_rounded,
                        color: _isCorrect
                            ? AppColors.leafGreen
                            : AppColors.terracotta,
                        label: 'Tiếp tục',
                        onPressed: () {
                          setState(() {
                            _currentIndex++;
                            _resetQuestion();
                          });
                        },
                      ),
                  ],
                ),
              ),
            );
          },
          loading: () => const AppLoadingIndicator(color: AppColors.terracotta),
          error: (error, _) => AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Không thể tải câu',
            message: '$error',
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double progress) {
    return AppBar(
      title: const Text('Luyện câu', style: AppTypography.headingM),
      backgroundColor: AppColors.cream.withValues(alpha: 0.94),
      foregroundColor: AppColors.slateGrey,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: AppColors.creamDark,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.terracotta),
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

  void _syncSession(List<Sentence> sentences) {
    final signature = sentences.map((sentence) => sentence.id).join('|');
    if (_sessionSignature == signature && _sessionQueue.isNotEmpty) return;

    _sessionSignature = signature;
    _sessionQueue
      ..clear()
      ..addAll(sentences.take(_targetSessionLength));
    _currentIndex = 0;
    _completedCount = 0;
    _correctCount = 0;
    _retryCount = 0;
    _streak = 0;
    _progress = 0;
    _resetQuestion();
  }

  List<String> _optionsFor(Sentence sentence, List<Sentence> allSentences) {
    final answer = _expectedAnswer(sentence);
    final key = '${_mode.name}:${sentence.id}:$answer';
    if (_optionsKey == key && _currentOptions.isNotEmpty) {
      return _currentOptions;
    }

    final preferredPool = allSentences.where(
      (item) =>
          item.id != sentence.id &&
          item.jlptLevel == sentence.jlptLevel &&
          _candidateAnswer(item).isNotEmpty,
    );
    final fallbackPool = allSentences.where(
      (item) => item.id != sentence.id && _candidateAnswer(item).isNotEmpty,
    );
    final distractors = [
      ...preferredPool.map(_candidateAnswer),
      ...fallbackPool.map(_candidateAnswer),
    ].where((option) => option != answer).toSet().toList()..shuffle();

    _currentOptions = ([...distractors.take(3), answer]..shuffle());
    _optionsKey = key;
    return _currentOptions;
  }

  String _candidateAnswer(Sentence sentence) {
    return _mode == SentencePracticeMode.meaningToJapanese
        ? sentence.text
        : sentence.meaning;
  }

  String _expectedAnswer(Sentence sentence) {
    return _mode == SentencePracticeMode.readToMeaning
        ? sentence.meaning
        : sentence.text;
  }

  bool get _canCheck {
    return switch (_mode) {
      SentencePracticeMode.typing => _typedAnswer.trim().isNotEmpty,
      _ => _selectedAnswer != null,
    };
  }

  void _check(Sentence sentence) {
    if (_isChecked) return;

    final expected = _expectedAnswer(sentence);
    final actual = _mode == SentencePracticeMode.typing
        ? _typedAnswer
        : _selectedAnswer ?? '';
    final isCorrect = QuizAnswerNormalizer.isCorrect(actual, expected);

    ref.read(emitSentenceStudyEventProvider)(
      sentence.id,
      isCorrect ? (_showHint ? 3 : 4) : 1,
    );

    setState(() {
      _isCorrect = isCorrect;
      _isChecked = true;
      _completedCount++;
      if (isCorrect) {
        _correctCount++;
        _streak++;
      } else {
        _streak = 0;
        _retryCount++;
        _sessionQueue.add(sentence);
      }
    });
  }

  void _resetSession() {
    setState(() {
      _sessionSignature = '';
      _sessionQueue.clear();
      _currentIndex = 0;
      _completedCount = 0;
      _correctCount = 0;
      _retryCount = 0;
      _streak = 0;
      _progress = 0;
      _resetQuestion();
    });
  }

  void _restartSession() {
    ref.invalidate(dueSentencePracticeProvider);
    _resetSession();
  }

  void _resetQuestion() {
    _optionsKey = null;
    _currentOptions = const [];
    _selectedAnswer = null;
    _typedAnswer = '';
    _isChecked = false;
    _isCorrect = false;
    _showHint = false;
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

class _SentenceSessionSummary extends StatelessWidget {
  final int completedCount;
  final int totalCount;
  final int correctCount;
  final int retryCount;
  final int streak;

  const _SentenceSessionSummary({
    required this.completedCount,
    required this.totalCount,
    required this.correctCount,
    required this.retryCount,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0
        ? 0.0
        : (completedCount / totalCount).clamp(0.0, 1.0);
    final accuracy = completedCount == 0
        ? 0
        : ((correctCount / completedCount) * 100).round();

    return AppCard(
      key: sentenceSessionSummaryKey,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      color: AppColors.white,
      borderColor: AppColors.slateLight.withValues(alpha: 0.22),
      shadowColor: AppColors.ink.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Phiên học 10 câu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$completedCount/$totalCount',
                style: AppTypography.label.copyWith(
                  color: AppColors.terracotta,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.creamDark,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.terracotta,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Wrap(
            spacing: AppSpacing.sp4,
            runSpacing: AppSpacing.sp4,
            children: [
              _StudyMetricPill(
                icon: Icons.track_changes_rounded,
                label: '$accuracy% đúng',
                color: AppColors.leafGreen,
              ),
              _StudyMetricPill(
                icon: Icons.local_fire_department_rounded,
                label: 'Chuỗi $streak',
                color: AppColors.sunGold,
              ),
              _StudyMetricPill(
                icon: Icons.replay_rounded,
                label: retryCount == 0 ? '0 ôn lại' : '$retryCount ôn lại',
                color: AppColors.terracotta,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudyMetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StudyMetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.labelS.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceLearningAid extends StatelessWidget {
  final Sentence sentence;
  final SentencePracticeMode mode;
  final bool showHint;
  final VoidCallback onToggleHint;

  const _SentenceLearningAid({
    required this.sentence,
    required this.mode,
    required this.showHint,
    required this.onToggleHint,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp8),
      color: AppColors.navySoft.withValues(alpha: 0.56),
      borderColor: AppColors.slateLight.withValues(alpha: 0.20),
      shadowColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.terracotta,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.sp4),
              Expanded(
                child: Text(
                  _studyInstruction,
                  maxLines: showHint ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              OutlinedButton.icon(
                key: sentenceHintButtonKey,
                onPressed: onToggleHint,
                icon: Icon(
                  showHint
                      ? Icons.visibility_off_rounded
                      : Icons.lightbulb_outline_rounded,
                  size: 16,
                ),
                label: Text(showHint ? 'Ẩn gợi ý' : 'Gợi ý'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.terracotta,
                  side: BorderSide(
                    color: AppColors.terracotta.withValues(alpha: 0.34),
                  ),
                  textStyle: AppTypography.label.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                  visualDensity: const VisualDensity(
                    horizontal: -2,
                    vertical: -4,
                  ),
                ),
              ),
            ],
          ),
          if (showHint) ...[
            const SizedBox(height: AppSpacing.sp4),
            if (sentence.sourceGrammarTitle?.isNotEmpty ?? false)
              _InfoBlock(
                icon: Icons.account_tree_rounded,
                text: 'Mẫu ngữ pháp: ${sentence.sourceGrammarTitle}',
              ),
            if (sentence.reading.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp4),
              _InfoBlock(
                icon: Icons.record_voice_over_rounded,
                text: sentence.reading,
              ),
            ],
          ],
        ],
      ),
    );
  }

  String get _studyInstruction {
    return switch (mode) {
      SentencePracticeMode.readToMeaning =>
        'Đọc câu theo cụm trước, đoán ý chính rồi mới chọn đáp án.',
      SentencePracticeMode.meaningToJapanese =>
        'Nhớ khung câu Nhật: chủ đề, trợ từ, động từ/đuôi câu.',
      SentencePracticeMode.typing =>
        'Gõ lại từ trí nhớ. Nếu kẹt, mở gợi ý rồi tự hoàn thiện câu.',
    };
  }
}

class _SentenceSessionComplete extends StatelessWidget {
  final int completedCount;
  final int correctCount;
  final int retryCount;
  final VoidCallback onRestart;

  const _SentenceSessionComplete({
    required this.completedCount,
    required this.correctCount,
    required this.retryCount,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = completedCount == 0
        ? 0
        : ((correctCount / completedCount) * 100).round();

    return Center(
      child: AppCard(
        key: sentenceCompletionKey,
        padding: const EdgeInsets.all(AppSpacing.sp16),
        color: AppColors.white,
        borderColor: AppColors.leafGreen.withValues(alpha: 0.28),
        shadowColor: AppColors.leafGreen.withValues(alpha: 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.leafGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.leafGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp12),
                Expanded(
                  child: Text(
                    'Hoàn thành phiên học',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sp12),
            _InfoBlock(
              icon: Icons.insights_rounded,
              text:
                  'Bạn đã xử lý $completedCount lượt câu, đúng $accuracy%. '
                  '${retryCount == 0 ? 'Không có câu cần học lại.' : 'Các câu sai đã được đưa lại vào cuối phiên.'}',
            ),
            const SizedBox(height: AppSpacing.sp12),
            PrimaryButton(
              icon: Icons.refresh_rounded,
              color: AppColors.terracotta,
              label: 'Luyện phiên mới',
              onPressed: onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: counter + JLPT badge (matches _GrammarReviewHeader)
// ---------------------------------------------------------------------------

class _SentenceHeader extends StatelessWidget {
  final int current;
  final int total;

  const _SentenceHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp4,
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

// ---------------------------------------------------------------------------
// Mode selector pills (compact chip row)
// ---------------------------------------------------------------------------

class _SentenceModePills extends StatelessWidget {
  final SentencePracticeMode mode;
  final ValueChanged<SentencePracticeMode> onChanged;

  const _SentenceModePills({required this.mode, required this.onChanged});

  static const _modes = [
    (SentencePracticeMode.readToMeaning, Icons.translate_rounded, 'Nghĩa'),
    (SentencePracticeMode.meaningToJapanese, Icons.subject_rounded, 'Câu'),
    (SentencePracticeMode.typing, Icons.keyboard_rounded, 'Gõ'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp4),
        itemCount: _modes.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp8),
        itemBuilder: (context, index) {
          final (value, icon, label) = _modes[index];
          final selected = mode == value;
          return ChoiceChip(
            key: value == SentencePracticeMode.typing
                ? sentenceModeTypingKey
                : null,
            selected: selected,
            avatar: Icon(
              icon,
              size: 16,
              color: selected ? AppColors.white : AppColors.terracotta,
            ),
            label: Text(label),
            showCheckmark: false,
            onSelected: (_) => onChanged(value),
            labelStyle: AppTypography.label.copyWith(
              color: selected ? AppColors.white : AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
            backgroundColor: AppColors.white,
            selectedColor: AppColors.terracotta,
            side: BorderSide(
              color: selected
                  ? AppColors.terracotta
                  : AppColors.slateLight.withValues(alpha: 0.35),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Prompt card (matches _GrammarPromptCard)
// ---------------------------------------------------------------------------

class _SentencePromptCard extends StatelessWidget {
  final Sentence sentence;
  final SentencePracticeMode mode;
  final ValueChanged<String> onSpeak;

  const _SentencePromptCard({
    required this.sentence,
    required this.mode,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final prompt = switch (mode) {
      SentencePracticeMode.readToMeaning => sentence.text,
      SentencePracticeMode.meaningToJapanese => sentence.meaning,
      SentencePracticeMode.typing => sentence.meaning,
    };
    final isJapanesePrompt = mode == SentencePracticeMode.readToMeaning;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp8),
      color: AppColors.white,
      borderColor: AppColors.terracotta.withValues(alpha: 0.16),
      shadowColor: AppColors.terracotta.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Source grammar pill
          if (sentence.sourceGrammarTitle?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sp4),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                  child: Text(
                    sentence.sourceGrammarTitle!,
                    style: AppTypography.labelS.copyWith(
                      color: AppColors.terracotta,
                    ),
                  ),
                ),
              ),
            ),

          // Main prompt text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  prompt,
                  style:
                      (isJapanesePrompt
                              ? AppTypography.headingM
                              : AppTypography.bodyMBold)
                          .copyWith(color: AppColors.ink),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              if (isJapanesePrompt) ...[
                const SizedBox(width: AppSpacing.sp4),
                IconButton.filledTonal(
                  tooltip: 'Phát âm',
                  onPressed: () => onSpeak(sentence.text),
                  icon: const Icon(Icons.volume_up_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.terracotta.withValues(
                      alpha: 0.10,
                    ),
                    foregroundColor: AppColors.terracotta,
                    minimumSize: const Size.square(34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),

          // Reading (furigana)
          if (sentence.reading.isNotEmpty && isJapanesePrompt) ...[
            const SizedBox(height: 2),
            Text(
              sentence.reading,
              style: AppTypography.labelS.copyWith(
                color: AppColors.slateMuted,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Typing input
// ---------------------------------------------------------------------------

class _TypingInput extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onChanged;

  const _TypingInput({required this.enabled, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      onChanged: onChanged,
      style: AppTypography.bodyM.copyWith(
        color: AppColors.navyDark,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.white,
        hintText: 'Nhập câu tiếng Nhật...',
        hintStyle: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          borderSide: BorderSide(
            color: AppColors.slateLight.withValues(alpha: 0.42),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          borderSide: BorderSide(
            color: AppColors.slateLight.withValues(alpha: 0.42),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp12,
          vertical: AppSpacing.sp8,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Option list (matches _GrammarOptionList)
// ---------------------------------------------------------------------------

class _SentenceOptionList extends StatelessWidget {
  final Sentence sentence;
  final SentencePracticeMode mode;
  final List<String> options;
  final String? selectedAnswer;
  final bool isChecked;
  final ValueChanged<String> onSelect;

  const _SentenceOptionList({
    required this.sentence,
    required this.mode,
    required this.options,
    required this.selectedAnswer,
    required this.isChecked,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final answer = mode == SentencePracticeMode.meaningToJapanese
        ? sentence.text
        : sentence.meaning;

    return Column(
      children: [
        for (final option in options) ...[
          _SentenceOptionTile(
            option: option,
            isSelected: selectedAnswer == option,
            isCorrect: option == answer,
            isChecked: isChecked,
            onTap: () => onSelect(option),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Option tile (matches _GrammarOptionTile)
// ---------------------------------------------------------------------------

class _SentenceOptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isChecked;
  final VoidCallback onTap;

  const _SentenceOptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color backgroundColor;
    final IconData? icon;

    if (isChecked && isCorrect) {
      borderColor = AppColors.leafGreen;
      backgroundColor = AppColors.leafGreen.withValues(alpha: 0.10);
      icon = Icons.check_circle_rounded;
    } else if (isChecked && isSelected) {
      borderColor = AppColors.terracotta;
      backgroundColor = AppColors.terracotta.withValues(alpha: 0.08);
      icon = Icons.info_rounded;
    } else if (isSelected) {
      borderColor = AppColors.terracotta;
      backgroundColor = AppColors.terracotta.withValues(alpha: 0.08);
      icon = Icons.radio_button_checked_rounded;
    } else {
      borderColor = AppColors.slateLight.withValues(alpha: 0.42);
      backgroundColor = AppColors.white;
      icon = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: _sentenceOptionKey(option),
        onTap: isChecked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp8,
            vertical: AppSpacing.sp8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: isSelected || isCorrect
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: AppSpacing.sp8),
                Icon(icon, color: borderColor, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Answer panel (matches _GrammarAnswerPanel)
// ---------------------------------------------------------------------------

class _SentenceAnswerPanel extends StatelessWidget {
  final Sentence sentence;
  final SentencePracticeMode mode;
  final bool isCorrect;
  final String? selectedAnswer;
  final String typedAnswer;
  final bool wasHintUsed;
  final bool willRetry;
  final VoidCallback onSpeak;

  const _SentenceAnswerPanel({
    required this.sentence,
    required this.mode,
    required this.isCorrect,
    required this.selectedAnswer,
    required this.typedAnswer,
    required this.wasHintUsed,
    required this.willRetry,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final answer = switch (mode) {
      SentencePracticeMode.readToMeaning => sentence.meaning,
      SentencePracticeMode.meaningToJapanese => sentence.text,
      SentencePracticeMode.typing => sentence.text,
    };
    final accentColor = isCorrect ? AppColors.leafGreen : AppColors.terracotta;
    final userAnswer = mode == SentencePracticeMode.typing
        ? typedAnswer
        : selectedAnswer;

    return AppCard(
      key: isCorrect ? sentenceCorrectFeedbackKey : null,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      color: AppColors.white,
      borderColor: accentColor.withValues(alpha: 0.34),
      shadowColor: AppColors.ink.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: accentColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Expanded(
                child: Text(
                  isCorrect ? 'Chính xác' : 'Đáp án đúng',
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Phát âm',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_rounded),
                color: AppColors.terracotta,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            answer,
            style: AppTypography.bodyMBold.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!isCorrect && userAnswer != null) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              'Bạn chọn: $userAnswer',
              style: AppTypography.bodyS.copyWith(color: AppColors.terracotta),
            ),
          ],
          const SizedBox(height: AppSpacing.sp4),
          _InfoBlock(
            icon: isCorrect
                ? Icons.tips_and_updates_rounded
                : Icons.replay_rounded,
            text: _feedbackText,
          ),
          if (sentence.meaning != answer) ...[
            const SizedBox(height: AppSpacing.sp4),
            _InfoBlock(icon: Icons.translate_rounded, text: sentence.meaning),
          ],
          if (sentence.reading.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            _InfoBlock(
              icon: Icons.record_voice_over_rounded,
              text: sentence.reading,
            ),
          ],
        ],
      ),
    );
  }

  String get _feedbackText {
    if (!isCorrect && willRetry) {
      return 'Câu này sẽ quay lại cuối phiên. Hãy đọc đáp án thành tiếng một lần trước khi tiếp tục.';
    }
    if (wasHintUsed) {
      return 'Bạn nhớ được sau khi dùng gợi ý. Lần sau thử chờ thêm vài giây trước khi mở gợi ý.';
    }
    return 'Tốt. Hãy đọc lại câu Nhật một lần để nối âm, nghĩa và cấu trúc.';
  }
}

// ---------------------------------------------------------------------------
// Info block (matches grammar review _InfoBlock)
// ---------------------------------------------------------------------------

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBlock({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp8),
      decoration: BoxDecoration(
        color: AppColors.navySoft.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.terracotta),
          const SizedBox(width: AppSpacing.sp4),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyS.copyWith(color: AppColors.navyDark),
            ),
          ),
        ],
      ),
    );
  }
}
