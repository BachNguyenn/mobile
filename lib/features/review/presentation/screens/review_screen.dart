import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/learning/domain/services/quiz_answer_normalizer.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/review/presentation/providers/review_controller.dart';
import 'package:mobile/features/review/presentation/widgets/review_handwriting_area.dart';
import 'package:mobile/features/review/presentation/widgets/review_rating_buttons.dart';
import 'package:mobile/presentation/widgets/handwriting_canvas.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

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
          child: Center(
            child: AppEmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Không có mục cần ôn',
              message: 'Các thẻ hôm nay đã gọn gàng. Quay lại học bài mới nhé.',
            ),
          ),
        ),
      );
    }

    final state = ref.watch(reviewControllerProvider(widget.items));
    final controller = ref.read(
      reviewControllerProvider(widget.items).notifier,
    );
    ref.listen(reviewControllerProvider(widget.items), (previous, next) {
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previous?.errorMessage) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    if (state.isFinished) {
      return _ReviewCompleteView(reviewedCount: widget.items.length);
    }

    final item = widget.items[state.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Ôn tập SRS', style: AppTypography.headingS),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
      ),
      body: AppPageBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp8,
            AppSpacing.sp16,
            AppSpacing.sp20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReviewSessionHeader(
                current: state.currentIndex + 1,
                total: widget.items.length,
                item: item,
              ),
              const SizedBox(height: AppSpacing.sp12),
              _ReviewPrompt(item: item),
              const SizedBox(height: AppSpacing.sp12),
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
              const SizedBox(height: AppSpacing.sp16),
              if (!state.showAnswer)
                PrimaryButton(
                  icon: Icons.fact_check_rounded,
                  color: _ReviewVisuals.accent(item.type),
                  onPressed: _canSubmit(item, state)
                      ? () => controller.handleCheck()
                      : null,
                  label: item.usesHandwriting || item.choices.isNotEmpty
                      ? 'Kiểm tra & xem đáp án'
                      : state.typedAnswer.trim().isNotEmpty
                      ? 'Kiểm tra'
                      : 'Xem đáp án',
                )
              else if (state.isSubmitting)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.mossGreen),
                )
              else
                ReviewRatingButtons(
                  enabled: !state.isSubmitting,
                  onRate: (rating) async {
                    await controller.handleRating(rating);
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

class _ReviewCompleteView extends ConsumerWidget {
  final int reviewedCount;

  const _ReviewCompleteView({required this.reviewedCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPlan = ref.watch(dailyStudyPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppPageBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sp20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sp20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.leafGreen,
                        AppColors.navy,
                        AppColors.navyDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -18,
                        bottom: -24,
                        child: Icon(
                          Icons.task_alt_rounded,
                          size: 124,
                          color: AppColors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusL,
                              ),
                            ),
                            child: const Icon(
                              Icons.task_alt_rounded,
                              color: AppColors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sp16),
                          Text(
                            'Hoàn thành phiên ôn',
                            style: AppTypography.headingL.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                              height: 1.18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sp8),
                          Text(
                            'Bạn đã xử lý $reviewedCount mục. Lịch ôn đã được cập nhật theo kết quả vừa chấm.',
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.white.withValues(alpha: 0.76),
                              height: 1.35,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sp16),
                _ReviewNextActionCard(plan: nextPlan),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Về trang trước'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewNextActionCard extends ConsumerWidget {
  final AsyncValue<DailyStudyPlan> plan;

  const _ReviewNextActionCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = plan.valueOrNull;
    if (next == null) {
      return const AppCard(
        child: SizedBox(
          height: 48,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.leafGreen),
          ),
        ),
      );
    }

    return AppCard(
      onTap: () => openDailyStudyPlan(context, ref, next),
      color: AppColors.leafGreen.withValues(alpha: 0.08),
      borderColor: AppColors.leafGreen.withValues(alpha: 0.18),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: AppColors.leafGreen),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiếp theo',
                  style: AppTypography.label.copyWith(
                    color: AppColors.leafGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  next.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
                ),
                Text(
                  next.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppColors.leafGreen),
        ],
      ),
    );
  }
}

abstract final class _ReviewVisuals {
  static Color accent(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.vocabulary => AppColors.waterBlue,
      ReviewItemType.grammar => AppColors.terracotta,
      ReviewItemType.kanji => AppColors.navy,
      ReviewItemType.sentence => AppColors.leafGreen,
    };
  }

  static Color progressColor(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.vocabulary => AppColors.leafLight,
      ReviewItemType.grammar => AppColors.sunGold,
      ReviewItemType.kanji => AppColors.waterBlue,
      ReviewItemType.sentence => AppColors.leafLight,
    };
  }

  static LinearGradient gradient(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.vocabulary => const LinearGradient(
        colors: [AppColors.waterBlue, AppColors.leafGreen],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ReviewItemType.grammar => const LinearGradient(
        colors: [AppColors.terracotta, AppColors.sunGold, AppColors.leafDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ReviewItemType.kanji => const LinearGradient(
        colors: [AppColors.navyDark, AppColors.navy, AppColors.slateGrey],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      ReviewItemType.sentence => const LinearGradient(
        colors: [AppColors.leafGreen, AppColors.navy],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    };
  }

  static IconData icon(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.vocabulary => Icons.style_rounded,
      ReviewItemType.grammar => Icons.schema_rounded,
      ReviewItemType.kanji => Icons.brush_rounded,
      ReviewItemType.sentence => Icons.subject_rounded,
    };
  }

  static String label(ReviewItemType type) {
    return switch (type) {
      ReviewItemType.vocabulary => 'Từ vựng',
      ReviewItemType.grammar => 'Ngữ pháp',
      ReviewItemType.kanji => 'Chữ Hán',
      ReviewItemType.sentence => 'Câu ví dụ',
    };
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
    final accent = _ReviewVisuals.accent(item.type);
    final isKanji = item.type == ReviewItemType.kanji;
    final isKnowledgePrompt =
        item.type == ReviewItemType.vocabulary ||
        item.type == ReviewItemType.sentence ||
        isKanji;

    return AppCard(
      color: accent.withValues(alpha: 0.08),
      borderColor: accent.withValues(alpha: 0.18),
      shadowColor: accent.withValues(alpha: 0.06),
      padding: const EdgeInsets.all(AppSpacing.sp16),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -18,
            child: isKanji
                ? Text(
                    '字',
                    style: AppTypography.kanjiHero.copyWith(
                      color: accent.withValues(alpha: 0.08),
                      fontSize: 104,
                      height: 1,
                    ),
                  )
                : Icon(
                    _ReviewVisuals.icon(item.type),
                    size: 92,
                    color: accent.withValues(alpha: 0.08),
                  ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  JlptLevelBadge(level: item.jlptLevel, color: accent),
                  const SizedBox(width: AppSpacing.sp8),
                  _TypeMiniPill(item: item, accent: accent),
                  if (_showSpeaker) ...[
                    const SizedBox(width: AppSpacing.sp8),
                    IconButton.filledTonal(
                      tooltip: 'Phát âm',
                      onPressed: () => _speak(ref, item.prompt),
                      icon: const Icon(Icons.volume_up_rounded, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: accent.withValues(alpha: 0.12),
                        foregroundColor: accent,
                        minimumSize: const Size(36, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              Text(
                item.prompt,
                style:
                    (isKnowledgePrompt
                            ? AppTypography.kanjiHero
                            : AppTypography.headingL)
                        .copyWith(
                          color: AppColors.ink,
                          fontSize: isKanji
                              ? 42
                              : isKnowledgePrompt
                              ? 32
                              : 24,
                          height: 1.16,
                        ),
                textAlign: TextAlign.center,
              ),
              if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sp8),
                Text(
                  item.subtitle!,
                  style: AppTypography.bodyS.copyWith(
                    color: AppColors.slateGrey,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
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

class _TypeMiniPill extends StatelessWidget {
  final ReviewItem item;
  final Color accent;

  const _TypeMiniPill({required this.item, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ReviewVisuals.icon(item.type), color: accent, size: 14),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            _ReviewVisuals.label(item.type),
            style: AppTypography.labelS.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSessionHeader extends StatelessWidget {
  final int current;
  final int total;
  final ReviewItem item;

  const _ReviewSessionHeader({
    required this.current,
    required this.total,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final progress = current / total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      decoration: BoxDecoration(
        gradient: _ReviewVisuals.gradient(item.type),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -24,
            child: Icon(
              _ReviewVisuals.icon(item.type),
              size: 108,
              color: AppColors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    ),
                    child: Icon(
                      _ReviewVisuals.icon(item.type),
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phiên ôn SRS',
                          style: AppTypography.headingS.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          '${_ReviewVisuals.label(item.type)} · $current/$total thẻ',
                          style: AppTypography.label.copyWith(
                            color: AppColors.white.withValues(alpha: 0.74),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sp8,
                      vertical: AppSpacing.sp4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: AppTypography.labelS.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.white.withValues(alpha: 0.16),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _ReviewVisuals.progressColor(item.type),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewWorkspaceHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _ReviewWorkspaceHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
          ),
          child: Icon(icon, color: accent, size: 18),
        ),
        const SizedBox(width: AppSpacing.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  color: AppColors.slateMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
    final accent = _ReviewVisuals.accent(item.type);

    return Column(
      children: [
        _ReviewWorkspaceHeader(
          icon: Icons.brush_rounded,
          title: 'Viết chữ Hán',
          subtitle: 'Viết vào ô rồi kiểm tra nét nhận diện',
          accent: accent,
        ),
        const SizedBox(height: AppSpacing.sp12),
        Expanded(
          child: Stack(
            children: [
              ReviewHandwritingArea(
                canvasKey: canvasKey,
                onDrawingChanged: controller.onDrawingChanged,
                onClear: controller.resetCanvas,
                accent: accent,
              ),
              if (state.showAnswer)
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
                            item.answer,
                            style: TextStyle(
                              fontSize: 112,
                              fontFamily: 'Serif',
                              color: isCorrect ? accent : AppColors.terracotta,
                            ),
                          ),
                          if (state.recognizedText != null)
                            Text(
                              'Bạn viết: ${state.recognizedText}',
                              style: AppTypography.bodyM.copyWith(
                                color: isCorrect
                                    ? accent
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
                child: IconButton.filledTonal(
                  tooltip: 'Xóa nét viết',
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white.withValues(alpha: 0.88),
                    foregroundColor: accent,
                  ),
                  onPressed: () {
                    canvasKey.currentState?.clear();
                    controller.resetCanvas();
                  },
                ),
              ),
            ],
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
    final accent = _ReviewVisuals.accent(item.type);

    // ── Show Answer State ──────────────────────────────────
    if (state.showAnswer) {
      return _AnswerReveal(item: item, state: state);
    }

    // ── Multiple Choice ───────────────────────────────────
    if (item.choices.isNotEmpty) {
      return Column(
        children: [
          _ReviewWorkspaceHeader(
            icon: Icons.checklist_rounded,
            title: 'Chọn đáp án',
            subtitle: 'Chọn một phương án rồi kiểm tra',
            accent: accent,
          ),
          const SizedBox(height: AppSpacing.sp12),
          Expanded(
            child: ListView.separated(
              itemCount: item.choices.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sp12),
              itemBuilder: (context, index) {
                final choice = item.choices[index];
                final isSelected = state.selectedChoice == choice;
                return AppCard(
                  onTap: () => onSelectChoice(choice),
                  color: isSelected
                      ? accent.withValues(alpha: 0.10)
                      : AppColors.white,
                  borderColor: isSelected
                      ? accent
                      : AppColors.slateLight.withValues(alpha: 0.35),
                  shadowColor: isSelected
                      ? accent.withValues(alpha: 0.06)
                      : AppColors.ink.withValues(alpha: 0.03),
                  padding: const EdgeInsets.all(AppSpacing.sp12),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: (isSelected ? accent : AppColors.slateMuted)
                              .withValues(alpha: isSelected ? 0.14 : 0.08),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusS,
                          ),
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: isSelected ? accent : AppColors.slateMuted,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sp12),
                      Expanded(
                        child: Text(
                          choice,
                          style: AppTypography.bodyM.copyWith(
                            color: isSelected ? accent : AppColors.ink,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    // ── Typing Input (Vocabulary free-recall) ──────────────
    if (item.type == ReviewItemType.vocabulary) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewWorkspaceHeader(
            icon: Icons.keyboard_rounded,
            title: 'Gõ nghĩa',
            subtitle: 'Tự nhớ trước khi xem đáp án',
            accent: accent,
          ),
          const SizedBox(height: AppSpacing.sp12),
          Expanded(
            child: Center(
              child: AppCard(
                color: AppColors.white,
                borderColor: accent.withValues(alpha: 0.16),
                shadowColor: accent.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(AppSpacing.sp16),
                child: TextField(
                  onChanged: onTypedAnswer,
                  textInputAction: TextInputAction.done,
                  style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.creamDark.withValues(alpha: 0.36),
                    hintText: 'Nhập đáp án...',
                    prefixIcon: Icon(Icons.keyboard_rounded, color: accent),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      borderSide: BorderSide(
                        color: AppColors.slateLight.withValues(alpha: 0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                      borderSide: BorderSide(color: accent, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Flip Card (Grammar / Sentence free-recall) ────────
    return Column(
      children: [
        _ReviewWorkspaceHeader(
          icon: Icons.psychology_alt_rounded,
          title: 'Tự nhớ đáp án',
          subtitle: 'Nói thầm câu trả lời rồi lật gợi ý nếu cần',
          accent: accent,
        ),
        const SizedBox(height: AppSpacing.sp12),
        Expanded(child: _FlipCard(item: item)),
      ],
    );
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
    final isGrammar = widget.item.type == ReviewItemType.grammar;
    final accent = _ReviewVisuals.accent(widget.item.type);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp20),
      color: accent.withValues(alpha: 0.08),
      borderColor: accent.withValues(alpha: 0.18),
      shadowColor: accent.withValues(alpha: 0.06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            color: accent.withValues(alpha: 0.72),
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            isGrammar ? 'Tự nhớ ý nghĩa trước' : 'Chạm để xem gợi ý',
            style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sp4),
          Text(
            isGrammar
                ? 'Nói trong đầu mẫu này dùng khi nào, rồi xem cấu trúc/ví dụ để kiểm tra.'
                : 'Tự nhớ đáp án rồi bấm "Xem đáp án" bên dưới.',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    final isGrammar = widget.item.type == ReviewItemType.grammar;
    final accent = _ReviewVisuals.accent(widget.item.type);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp20),
      color: AppColors.white,
      borderColor: accent.withValues(alpha: 0.22),
      shadowColor: accent.withValues(alpha: 0.08),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGrammar) ...[
            Text(
              'Gợi ý, chưa phải đáp án',
              style: AppTypography.label.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sp12),
          ],
          if (widget.item.grammar?.formation.isNotEmpty ?? false) ...[
            Text(
              widget.item.grammar!.formation,
              style: AppTypography.bodyMBold.copyWith(color: accent),
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
            isGrammar
                ? 'Bấm "Kiểm tra & xem đáp án" để xem ý chính'
                : 'Chạm lại để lật',
            style: AppTypography.caption,
            textAlign: TextAlign.center,
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

    final showSpeaker =
        item.type == ReviewItemType.vocabulary ||
        item.type == ReviewItemType.sentence;
    final accent = isCorrect
        ? _ReviewVisuals.accent(item.type)
        : AppColors.terracotta;

    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sp16),
        color: accent.withValues(alpha: 0.08),
        borderColor: accent.withValues(alpha: 0.24),
        shadowColor: accent.withValues(alpha: 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: accent,
                  size: 36,
                ),
                if (showSpeaker) ...[
                  const SizedBox(width: AppSpacing.sp12),
                  IconButton.filledTonal(
                    tooltip: 'Phát âm đáp án',
                    onPressed: () => _speak(ref),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.waterBlue.withValues(
                        alpha: 0.12,
                      ),
                      foregroundColor: AppColors.waterBlue,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sp12),
            Text(
              item.type == ReviewItemType.grammar
                  ? 'Ý nghĩa: ${item.answer}'
                  : item.answer,
              style: AppTypography.headingS.copyWith(
                color: AppColors.ink,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
            if (state.typedAnswer.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp8),
              Text(
                'Bạn gõ: ${state.typedAnswer}',
                style: AppTypography.bodyM.copyWith(color: accent),
                textAlign: TextAlign.center,
              ),
            ],
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
    final textToSpeak = item.type == ReviewItemType.vocabulary
        ? item.prompt
        : item.prompt;
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
