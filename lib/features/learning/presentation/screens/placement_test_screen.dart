import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/bootstrap/database_initializer_provider.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/application/providers/grammar_repository_provider.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/kanji/application/providers/kanji_repository_provider.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/features/vocabulary/application/providers/vocabulary_repository_provider.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

final placementQuestionsProvider = FutureProvider<List<_PlacementQuestion>>((
  ref,
) async {
  await ref.watch(databaseInitializerProvider.future);

  final vocabulary = await ref
      .read(vocabularyRepositoryProvider)
      .getAllVocabulary();
  final kanji = await ref.read(kanjiRepositoryProvider).getAllCards();
  final grammar = await ref
      .read(grammarRepositoryProvider)
      .getAllGrammarPoints();

  return _PlacementQuestionFactory().build(
    vocabulary: vocabulary,
    kanji: kanji,
    grammar: grammar,
  );
});

class PlacementTestScreen extends ConsumerStatefulWidget {
  const PlacementTestScreen({super.key});

  @override
  ConsumerState<PlacementTestScreen> createState() =>
      _PlacementTestScreenState();
}

class _PlacementTestScreenState extends ConsumerState<PlacementTestScreen> {
  int _index = 0;
  int _score = 0;
  int? _recommendedLevel;
  bool _started = false;
  bool _isLocked = false;
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final currentLevel = ref.watch(selectedLevelProvider);
    final questionsAsync = ref.watch(placementQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra năng lực'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: AppPageBackground(
        child: SafeArea(
          top: false,
          child: questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.quiz_outlined,
                  title: 'Chưa có dữ liệu kiểm tra',
                  message:
                      'Hãy thử lại sau khi dữ liệu từ vựng, ngữ pháp và chữ Hán được nạp.',
                );
              }

              final maxScore = _maxScoreFor(questions);
              final safeIndex = min(_index, questions.length - 1);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _recommendedLevel != null
                    ? _ResultView(
                        key: const ValueKey('result'),
                        score: _score,
                        maxScore: maxScore,
                        level: _recommendedLevel!,
                        onDone: () => Navigator.pop(context),
                        onRestart: _restart,
                      )
                    : _started
                    ? _QuestionView(
                        key: ValueKey(safeIndex),
                        index: safeIndex,
                        total: questions.length,
                        question: questions[safeIndex],
                        selectedOption: _selectedOption,
                        isLocked: _isLocked,
                        onSelect: (option) => _onSelect(option, questions),
                      )
                    : _IntroView(
                        key: const ValueKey('intro'),
                        currentLevel: currentLevel,
                        total: questions.length,
                        onStart: () => setState(() => _started = true),
                      ),
              );
            },
            loading: () =>
                const AppLoadingIndicator(color: AppColors.leafGreen),
            error: (error, _) => AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Không tải được bài kiểm tra',
              message: 'Lỗi: $error',
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onSelect(
    String option,
    List<_PlacementQuestion> questions,
  ) async {
    if (_isLocked) return;
    if (questions.isEmpty || _index >= questions.length) return;

    final question = questions[_index];
    final isCorrect = option == question.answer;
    if (isCorrect) _score += question.weight;

    setState(() {
      _selectedOption = option;
      _isLocked = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;

    if (_index < questions.length - 1) {
      setState(() {
        _index += 1;
        _selectedOption = null;
        _isLocked = false;
      });
      return;
    }

    final level = _recommendLevel(_score, _maxScoreFor(questions));
    await ref.read(settingsProvider.notifier).updateCurrentJlptLevel(level);
    ref.read(selectedLevelProvider.notifier).state = level;
    setState(() {
      _recommendedLevel = level;
      _selectedOption = null;
      _isLocked = false;
    });
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _recommendedLevel = null;
      _started = true;
      _isLocked = false;
      _selectedOption = null;
    });
  }

  int _recommendLevel(int score, int maxScore) {
    if (maxScore <= 0) return 5;
    final ratio = score / maxScore;
    if (ratio >= 0.86) return 1;
    if (ratio >= 0.68) return 2;
    if (ratio >= 0.48) return 3;
    if (ratio >= 0.28) return 4;
    return 5;
  }

  int _maxScoreFor(List<_PlacementQuestion> questions) {
    return questions.fold<int>(0, (total, question) => total + question.weight);
  }
}

class _IntroView extends StatelessWidget {
  final int currentLevel;
  final int total;
  final VoidCallback onStart;

  const _IntroView({
    super.key,
    required this.currentLevel,
    required this.total,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sp24),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          gradient: AppColors.brandLeafGradient,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp20),
                Text(
                  'Định vị đúng trình độ',
                  style: AppTypography.headingL.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp8),
                Text(
                  '$total câu trộn từ vựng, ngữ pháp và chữ Hán. Sau bài kiểm tra, app sẽ gợi ý JLPT phù hợp để bạn học tiếp.',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.white.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: AppSpacing.sp20),
                Wrap(
                  spacing: AppSpacing.sp8,
                  runSpacing: AppSpacing.sp8,
                  children: [
                    _SoftPill(
                      icon: Icons.school_rounded,
                      label: 'Hiện tại N$currentLevel',
                      isLight: true,
                    ),
                    _SoftPill(
                      icon: Icons.timer_rounded,
                      label: 'Khoảng ${max(3, (total * 18 / 60).ceil())} phút',
                      isLight: true,
                    ),
                    _SoftPill(
                      icon: Icons.checklist_rounded,
                      label: '$total câu',
                      isLight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sp20),
        const _ChecklistCard(
          items: [
            'Không cần hoàn hảo, cứ chọn đáp án bạn thấy tự nhiên nhất.',
            'Câu hỏi sẽ tự chuyển sau khi bạn chọn.',
            'Kết quả chỉ dùng để gợi ý lộ trình học phù hợp hơn.',
          ],
        ),
        const SizedBox(height: AppSpacing.sp24),
        PrimaryButton(
          label: 'Bắt đầu kiểm tra',
          icon: Icons.play_arrow_rounded,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _QuestionView extends StatelessWidget {
  final int index;
  final int total;
  final _PlacementQuestion question;
  final String? selectedOption;
  final bool isLocked;
  final ValueChanged<String> onSelect;

  const _QuestionView({
    super.key,
    required this.index,
    required this.total,
    required this.question,
    required this.selectedOption,
    required this.isLocked,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (index + 1) / total;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sp24),
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: progress,
                  color: AppColors.mossGreen,
                  backgroundColor: AppColors.creamDark,
                  minHeight: 10,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sp12),
            Text(
              '${index + 1}/$total',
              style: AppTypography.bodyMBold.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sp20),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.sp24),
          color: AppColors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SoftPill(icon: question.icon, label: question.skill),
              const SizedBox(height: AppSpacing.sp20),
              Text(
                'Câu ${index + 1}',
                style: AppTypography.label.copyWith(
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                question.prompt,
                style: AppTypography.headingL.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sp20),
        ...question.options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
            child: _AnswerButton(
              label: option,
              isSelected: selectedOption == option,
              isCorrect: option == question.answer,
              showResult: isLocked,
              onPressed: isLocked ? null : () => onSelect(option),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int maxScore;
  final int level;
  final VoidCallback onDone;
  final VoidCallback onRestart;

  const _ResultView({
    super.key,
    required this.score,
    required this.maxScore,
    required this.level,
    required this.onDone,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (score / maxScore).clamp(0, 1).toDouble();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sp24),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.sp24),
          gradient: AppColors.brandLeafGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.sunGold,
                size: 46,
              ),
              const SizedBox(height: AppSpacing.sp16),
              Text(
                'Gợi ý trình độ của bạn',
                style: AppTypography.headingL.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                'Bạn nên tiếp tục từ JLPT N$level.',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: AppSpacing.sp20),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sp16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                        child: LinearProgressIndicator(
                          value: percent,
                          color: AppColors.mossGreen,
                          backgroundColor: AppColors.creamDark,
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Text(
                      '$score/$maxScore',
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sp20),
        PrimaryButton(
          label: 'Học theo lộ trình N$level',
          icon: Icons.route_rounded,
          onPressed: onDone,
        ),
        const SizedBox(height: AppSpacing.sp12),
        OutlinedButton.icon(
          onPressed: onRestart,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Làm lại bài kiểm tra'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppColors.navy,
            side: BorderSide(
              color: AppColors.slateLight.withValues(alpha: 0.6),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final List<String> items;

  const _ChecklistCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.white,
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.navySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: AppColors.mossGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sp12),
                    Expanded(child: Text(item, style: AppTypography.bodyS)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLight;

  const _SoftPill({
    required this.icon,
    required this.label,
    this.isLight = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isLight ? AppColors.white : AppColors.mossGreen;
    final background = isLight
        ? AppColors.white.withValues(alpha: 0.13)
        : AppColors.creamDark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(
          color: isLight
              ? AppColors.white.withValues(alpha: 0.16)
              : AppColors.slateLight.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            style: AppTypography.label.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback? onPressed;

  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final revealCorrect = showResult && isCorrect;
    final revealWrong = showResult && isSelected && !isCorrect;
    final borderColor = revealCorrect
        ? AppColors.success
        : revealWrong
        ? AppColors.error
        : AppColors.slateLight.withValues(alpha: 0.45);
    final background = revealCorrect
        ? AppColors.success.withValues(alpha: 0.10)
        : revealWrong
        ? AppColors.error.withValues(alpha: 0.10)
        : AppColors.white;
    final icon = revealCorrect
        ? Icons.check_circle_rounded
        : revealWrong
        ? Icons.cancel_rounded
        : Icons.radio_button_unchecked_rounded;
    final iconColor = revealCorrect
        ? AppColors.success
        : revealWrong
        ? AppColors.error
        : AppColors.slateMuted;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(AppSpacing.sp16),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMBold.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sp12),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacementQuestion {
  final String prompt;
  final List<String> options;
  final String answer;
  final int weight;
  final String skill;
  final IconData icon;

  const _PlacementQuestion({
    required this.prompt,
    required this.options,
    required this.answer,
    required this.weight,
    required this.skill,
    required this.icon,
  });
}

class _PlacementQuestionFactory {
  List<_PlacementQuestion> build({
    required List<Vocabulary> vocabulary,
    required List<KanjiCard> kanji,
    required List<GrammarPoint> grammar,
  }) {
    final questions = <_PlacementQuestion>[];
    final vocabularyPool = vocabulary
        .where((item) => item.word.isNotEmpty && item.meaning.isNotEmpty)
        .toList();
    final kanjiPool = kanji
        .where((item) => item.kanji.isNotEmpty && item.meanings.isNotEmpty)
        .toList();
    final grammarPool = grammar
        .where(
          (item) => item.title.isNotEmpty && item.shortExplanation.isNotEmpty,
        )
        .toList();
    final levels = {
      ...vocabularyPool.map((item) => item.jlptLevel),
      ...kanjiPool.map((item) => item.jlptLevel),
      ...grammarPool.map((item) => item.jlptLevel),
    }.where((level) => level > 0).toList()..sort((a, b) => b.compareTo(a));

    for (final level in levels) {
      final levelVocabulary = vocabularyPool
          .where((item) => item.jlptLevel == level)
          .toList();
      final levelKanji = kanjiPool
          .where((item) => item.jlptLevel == level)
          .toList();
      final levelGrammar = grammarPool
          .where((item) => item.jlptLevel == level)
          .toList();

      final vocabMeaning = _pick(levelVocabulary, level, 0);
      if (vocabMeaning != null) {
        final options = _options(
          correct: vocabMeaning.meaning,
          pool: vocabularyPool.map((item) => item.meaning),
          seed: vocabMeaning.id,
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Chọn nghĩa của 「${vocabMeaning.word}」',
              options: options,
              answer: vocabMeaning.meaning,
              weight: _weightForLevel(level),
              skill: 'Từ vựng',
              icon: Icons.menu_book_rounded,
            ),
          );
        }
      }

      final vocabReading = _pick(
        levelVocabulary
            .where(
              (item) => item.reading.isNotEmpty && item.reading != item.word,
            )
            .toList(),
        level,
        1,
      );
      if (vocabReading != null) {
        final options = _options(
          correct: vocabReading.reading,
          pool: vocabularyPool.map((item) => item.reading),
          seed: '${vocabReading.id}_reading',
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Chọn cách đọc của 「${vocabReading.word}」',
              options: options,
              answer: vocabReading.reading,
              weight: _weightForLevel(level),
              skill: 'Từ vựng',
              icon: Icons.menu_book_rounded,
            ),
          );
        }
      }

      final kanjiMeaning = _pick(levelKanji, level, 2);
      if (kanjiMeaning != null) {
        final options = _options(
          correct: kanjiMeaning.meanings,
          pool: kanjiPool.map((item) => item.meanings),
          seed: kanjiMeaning.id,
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Kanji 「${kanjiMeaning.kanji}」 thường mang nghĩa gì?',
              options: options,
              answer: kanjiMeaning.meanings,
              weight: _weightForLevel(level),
              skill: 'Chữ Hán',
              icon: Icons.translate_rounded,
            ),
          );
        }
      }

      final kanjiReading = _pick(
        levelKanji.where((item) => _primaryReading(item).isNotEmpty).toList(),
        level,
        3,
      );
      if (kanjiReading != null) {
        final answer = _primaryReading(kanjiReading);
        final options = _options(
          correct: answer,
          pool: kanjiPool.expand((item) => [item.onyomi, item.kunyomi]),
          seed: '${kanjiReading.id}_reading',
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Chọn cách đọc của 「${kanjiReading.kanji}」',
              options: options,
              answer: answer,
              weight: _weightForLevel(level),
              skill: 'Chữ Hán',
              icon: Icons.translate_rounded,
            ),
          );
        }
      }

      final grammarMeaning = _pick(levelGrammar, level, 4);
      if (grammarMeaning != null) {
        final options = _options(
          correct: grammarMeaning.shortExplanation,
          pool: grammarPool.map((item) => item.shortExplanation),
          seed: grammarMeaning.id,
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Mẫu 「${grammarMeaning.title}」 dùng để diễn tả ý nào?',
              options: options,
              answer: grammarMeaning.shortExplanation,
              weight: _weightForLevel(level) + 1,
              skill: 'Ngữ pháp',
              icon: Icons.edit_note_rounded,
            ),
          );
        }
      }

      final grammarFormation = _pick(
        levelGrammar.where((item) => item.formation.isNotEmpty).toList(),
        level,
        5,
      );
      if (grammarFormation != null) {
        final options = _options(
          correct: grammarFormation.formation,
          pool: grammarPool.map((item) => item.formation),
          seed: '${grammarFormation.id}_formation',
        );
        if (options.length >= 2) {
          questions.add(
            _PlacementQuestion(
              prompt: 'Chọn cấu trúc đúng của 「${grammarFormation.title}」',
              options: options,
              answer: grammarFormation.formation,
              weight: _weightForLevel(level) + 1,
              skill: 'Ngữ pháp',
              icon: Icons.edit_note_rounded,
            ),
          );
        }
      }
    }

    return List<_PlacementQuestion>.unmodifiable(questions);
  }

  T? _pick<T>(List<T> items, int level, int salt) {
    if (items.isEmpty) return null;
    final index = (level * 7 + salt * 11) % items.length;
    return items[index];
  }

  List<String> _options({
    required String correct,
    required Iterable<String> pool,
    required String seed,
  }) {
    final normalizedCorrect = correct.trim();
    final distractors =
        pool
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty && item != normalizedCorrect)
            .toSet()
            .toList()
          ..sort((a, b) => _score(seed, a).compareTo(_score(seed, b)));

    final options = [...distractors.take(3), normalizedCorrect]
      ..sort(
        (a, b) =>
            _score('${seed}_order', a).compareTo(_score('${seed}_order', b)),
      );
    return options;
  }

  int _score(String seed, String value) {
    return Object.hash(seed, value) & 0x7fffffff;
  }

  int _weightForLevel(int level) {
    return 7 - level;
  }

  String _primaryReading(KanjiCard card) {
    final onyomi = card.onyomi.trim();
    if (onyomi.isNotEmpty) return onyomi;
    return card.kunyomi.trim();
  }
}
