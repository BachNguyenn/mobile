import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/domain/entities/grammar_point.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_review_provider.dart';
import 'package:mobile/features/review/presentation/widgets/review_rating_buttons.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

const grammarReviewExampleKey = Key('grammarReviewExample');
const grammarReviewCheckButtonKey = Key('grammarReviewCheckButton');
const grammarReviewAnswerPanelKey = Key('grammarReviewAnswerPanel');

Key grammarReviewOptionKey(String option) => Key('grammarReviewOption:$option');

class GrammarReviewScreen extends ConsumerStatefulWidget {
  final List<GrammarPoint> items;

  const GrammarReviewScreen({super.key, required this.items});

  @override
  ConsumerState<GrammarReviewScreen> createState() =>
      _GrammarReviewScreenState();
}

class _GrammarReviewScreenState extends ConsumerState<GrammarReviewScreen> {
  List<GrammarPoint>? _allGrammar;
  GrammarReviewDeck? _deck;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAllGrammar);
  }

  Future<void> _loadAllGrammar() async {
    try {
      final grammar = await ref.read(grammarListProvider.future);
      if (!mounted) return;
      setState(() {
        _allGrammar = grammar;
        _deck = GrammarReviewDeck(items: widget.items, allGrammar: grammar);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: const AppPageBackground(
          child: AppEmptyState(
            icon: Icons.task_alt_rounded,
            message: 'Không có ngữ pháp nào cần ôn tập!',
          ),
        ),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: AppPageBackground(
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            message: 'Không thể tải dữ liệu ôn tập: $_loadError',
          ),
        ),
      );
    }

    final allGrammar = _allGrammar;
    if (allGrammar == null) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: const AppPageBackground(child: AppLoadingIndicator()),
      );
    }

    final deck =
        _deck ?? GrammarReviewDeck(items: widget.items, allGrammar: allGrammar);
    final state = ref.watch(grammarReviewControllerProvider(deck));
    final controller = ref.read(grammarReviewControllerProvider(deck).notifier);
    final question = state.currentQuestion;

    ref.listen(grammarReviewControllerProvider(deck), (previous, next) {
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(error)));
      }

      if (next.isFinished && !(previous?.isFinished ?? false)) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.maybeOf(context);
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        }
        messenger?.showSnackBar(
          const SnackBar(content: Text('Bạn đã hoàn thành phiên ôn ngữ pháp.')),
        );
      }
    });

    if (question == null) {
      return Scaffold(
        appBar: _buildAppBar(0),
        body: const AppPageBackground(
          child: AppEmptyState(
            icon: Icons.quiz_outlined,
            message: 'Chưa đủ dữ liệu để tạo câu hỏi ôn tập.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(state.progress),
      body: AppPageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp20,
              AppSpacing.sp16,
              AppSpacing.sp20,
              AppSpacing.sp20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _GrammarReviewHeader(
                  current: state.currentIndex + 1,
                  total: state.questions.length,
                  question: question,
                ),
                const SizedBox(height: AppSpacing.sp16),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _GrammarPromptCard(question: question),
                      const SizedBox(height: AppSpacing.sp16),
                      _GrammarOptionList(
                        question: question,
                        selectedAnswer: state.selectedAnswer,
                        isAnswerChecked: state.isAnswerChecked,
                        onSelect: controller.selectAnswer,
                      ),
                      if (state.isAnswerChecked) ...[
                        const SizedBox(height: AppSpacing.sp16),
                        _GrammarAnswerPanel(
                          question: question,
                          isCorrect: state.isCorrect,
                          selectedAnswer: state.selectedAnswer,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sp16),
                if (!state.isAnswerChecked)
                  PrimaryButton(
                    key: grammarReviewCheckButtonKey,
                    icon: Icons.fact_check_rounded,
                    color: AppColors.leafGreen,
                    label: 'Kiểm tra',
                    onPressed: state.selectedAnswer == null
                        ? null
                        : controller.checkAnswer,
                  )
                else if (state.isSubmitting)
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.leafGreen,
                    ),
                  )
                else
                  ReviewRatingButtons(onRate: controller.rateCurrent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double progress) {
    return AppBar(
      title: Text('Ôn ngữ pháp', style: AppTypography.headingM),
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
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.leafGreen),
        ),
      ),
    );
  }
}

class _GrammarReviewHeader extends StatelessWidget {
  final int current;
  final int total;
  final GrammarReviewQuestion question;

  const _GrammarReviewHeader({
    required this.current,
    required this.total,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$current/$total câu',
            style: AppTypography.bodyMBold.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        JlptLevelBadge(
          level: question.grammar.jlptLevel,
          color: AppColors.leafGreen,
        ),
      ],
    );
  }
}

class _GrammarPromptCard extends StatelessWidget {
  final GrammarReviewQuestion question;

  const _GrammarPromptCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final example = question.example;

    return AppCard(
      color: AppColors.white,
      borderColor: AppColors.leafGreen.withValues(alpha: 0.16),
      shadowColor: AppColors.leafGreen.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.grammar.title,
            style: AppTypography.headingM.copyWith(
              color: AppColors.navyDark,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp12),
          if (example != null && example.jp.isNotEmpty) ...[
            Text(
              example.jp,
              key: grammarReviewExampleKey,
              style: AppTypography.kanjiDisplay.copyWith(
                color: AppColors.ink,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
            if (example.romaji.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp8),
              Text(
                example.romaji,
                style: AppTypography.label.copyWith(
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ] else if (question.hint != null) ...[
            Text(
              question.hint!,
              key: grammarReviewExampleKey,
              style: AppTypography.headingS.copyWith(color: AppColors.leafDark),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.sp16),
          Text(
            question.prompt,
            style: AppTypography.bodyMBold.copyWith(
              color: AppColors.slateGrey,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _GrammarOptionList extends StatelessWidget {
  final GrammarReviewQuestion question;
  final String? selectedAnswer;
  final bool isAnswerChecked;
  final ValueChanged<String> onSelect;

  const _GrammarOptionList({
    required this.question,
    required this.selectedAnswer,
    required this.isAnswerChecked,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final option in question.options) ...[
          _GrammarOptionTile(
            option: option,
            isSelected: selectedAnswer == option,
            isCorrect: option == question.answer,
            isAnswerChecked: isAnswerChecked,
            onTap: () => onSelect(option),
          ),
          const SizedBox(height: AppSpacing.sp12),
        ],
      ],
    );
  }
}

class _GrammarOptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isAnswerChecked;
  final VoidCallback onTap;

  const _GrammarOptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isAnswerChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final Color backgroundColor;
    final IconData? icon;

    if (isAnswerChecked && isCorrect) {
      borderColor = AppColors.leafGreen;
      backgroundColor = AppColors.leafGreen.withValues(alpha: 0.10);
      icon = Icons.check_circle_rounded;
    } else if (isAnswerChecked && isSelected) {
      borderColor = AppColors.terracotta;
      backgroundColor = AppColors.terracotta.withValues(alpha: 0.08);
      icon = Icons.info_rounded;
    } else if (isSelected) {
      borderColor = AppColors.leafGreen;
      backgroundColor = AppColors.leafGreen.withValues(alpha: 0.08);
      icon = Icons.radio_button_checked_rounded;
    } else {
      borderColor = AppColors.slateLight.withValues(alpha: 0.42);
      backgroundColor = AppColors.white;
      icon = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: grammarReviewOptionKey(option),
        onTap: isAnswerChecked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sp16),
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
                const SizedBox(width: AppSpacing.sp12),
                Icon(icon, color: borderColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GrammarAnswerPanel extends StatelessWidget {
  final GrammarReviewQuestion question;
  final bool isCorrect;
  final String? selectedAnswer;

  const _GrammarAnswerPanel({
    required this.question,
    required this.isCorrect,
    required this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final example = question.example;

    return AppCard(
      key: grammarReviewAnswerPanelKey,
      color: AppColors.white,
      borderColor: (isCorrect ? AppColors.leafGreen : AppColors.terracotta)
          .withValues(alpha: 0.34),
      shadowColor: AppColors.ink.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                color: isCorrect ? AppColors.leafGreen : AppColors.terracotta,
              ),
              const SizedBox(width: AppSpacing.sp8),
              Expanded(
                child: Text(
                  isCorrect ? 'Đúng rồi' : 'Đáp án đúng',
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            question.answer,
            style: AppTypography.bodyMBold.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!isCorrect && selectedAnswer != null) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              'Bạn chọn: $selectedAnswer',
              style: AppTypography.bodyS.copyWith(color: AppColors.terracotta),
            ),
          ],
          if (question.hint != null) ...[
            const SizedBox(height: AppSpacing.sp12),
            _InfoBlock(icon: Icons.schema_rounded, text: question.hint!),
          ],
          if (example != null && example.en.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            _InfoBlock(icon: Icons.translate_rounded, text: example.en),
          ],
          if (question.explanation != null) ...[
            const SizedBox(height: AppSpacing.sp12),
            Text(
              question.explanation!,
              style: AppTypography.bodyS.copyWith(
                color: AppColors.slateGrey,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBlock({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.navySoft.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.leafGreen),
          const SizedBox(width: AppSpacing.sp8),
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
