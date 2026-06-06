import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';

class VocabularyListItem extends ConsumerStatefulWidget {
  final Vocabulary vocabulary;

  const VocabularyListItem({super.key, required this.vocabulary});

  @override
  ConsumerState<VocabularyListItem> createState() => _VocabularyListItemState();
}

class _VocabularyListItemState extends ConsumerState<VocabularyListItem> {
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    final vocabulary = widget.vocabulary;
    final example = vocabulary.exampleSentences.isNotEmpty
        ? vocabulary.exampleSentences.first
        : null;
    final isNew = vocabulary.reps == 0;

    final resolvedSlateLight = AppColors.resolve(AppColors.slateLight, context);
    final resolvedNavyDark = AppColors.resolve(AppColors.navyDark, context);
    final resolvedLeafGreen = AppColors.resolve(AppColors.leafGreen, context);

    return AppCard(
      padding: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      borderColor: resolvedSlateLight.withValues(alpha: 0.28),
      shadowColor: resolvedNavyDark.withValues(alpha: 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sp12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VocabularyMetaRow(vocabulary: vocabulary, isNew: isNew),
                      const SizedBox(height: AppSpacing.sp8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() => _showMeaning = !_showMeaning);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vocabulary.word,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.kanjiDisplay.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 28,
                                height: 1.05,
                              ),
                            ),
                            if (vocabulary.reading.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                vocabulary.reading,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.resolve(AppColors.slateMuted, context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sp4),
                            Row(
                              children: [
                                Icon(
                                  _showMeaning
                                      ? Icons.visibility_off_rounded
                                      : Icons.touch_app_rounded,
                                  size: 14,
                                  color: resolvedLeafGreen,
                                ),
                                const SizedBox(width: AppSpacing.sp4),
                                Text(
                                  _showMeaning
                                      ? 'Chạm để ẩn nghĩa'
                                      : 'Chạm từ để xem nghĩa',
                                  style: AppTypography.labelS.copyWith(
                                    color: resolvedLeafGreen,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sp8),
                Column(
                  children: [
                    _CircleIconButton(
                      tooltip: 'Phát âm',
                      icon: Icons.volume_up_rounded,
                      onTap: () async {
                        try {
                          await ref
                              .read(audioServiceProvider)
                              .speakJapanese(vocabulary.word);
                        } catch (_) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Không thể phát âm thanh trên thiết bị này.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    _CircleIconButton(
                      tooltip: 'Chi tiết',
                      icon: Icons.chevron_right_rounded,
                      onTap: () => Navigator.push(
                        context,
                        AppRoutes.vocabularyDetail(vocabulary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp12,
                    vertical: AppSpacing.sp8,
                  ),
                  decoration: BoxDecoration(
                    color: resolvedLeafGreen.withValues(alpha: 0.08),
                    border: Border(
                      top: BorderSide(
                        color: resolvedLeafGreen.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  child: Text(
                    vocabulary.meaning,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMBold.copyWith(
                      color: AppColors.resolve(AppColors.leafDark, context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (example != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sp12,
                      AppSpacing.sp8,
                      AppSpacing.sp12,
                      AppSpacing.sp12,
                    ),
                    child: _ExampleBlock(example: example),
                  ),
              ],
            ),
            crossFadeState: _showMeaning
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _VocabularyMetaRow extends StatelessWidget {
  final Vocabulary vocabulary;
  final bool isNew;

  const _VocabularyMetaRow({required this.vocabulary, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        JlptLevelBadge(level: vocabulary.jlptLevel, color: AppColors.leafGreen),
        if (isNew) ...[
          const SizedBox(width: AppSpacing.sp8),
          const _MiniBadge(label: 'Mới', color: AppColors.navy),
        ],
        if (vocabulary.partOfSpeech?.isNotEmpty == true) ...[
          const SizedBox(width: AppSpacing.sp8),
          Flexible(
            child: _MiniBadge(
              label: vocabulary.partOfSpeech!,
              color: AppColors.slateMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.resolve(AppColors.navySoft, context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.resolve(AppColors.navy, context).withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: AppColors.resolve(AppColors.navy, context), size: 19),
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: resolvedColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelS.copyWith(
          color: resolvedColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final VocabularyExample example;

  const _ExampleBlock({required this.example});

  @override
  Widget build(BuildContext context) {
    final resolvedNavy = AppColors.resolve(AppColors.navy, context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: AppColors.resolve(AppColors.navySoft, context).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: resolvedNavy,
                size: 17,
              ),
              const SizedBox(width: AppSpacing.sp4),
              Text(
                'Ví dụ',
                style: AppTypography.labelS.copyWith(
                  color: resolvedNavy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            example.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyS.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (example.meaning.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              example.meaning,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(color: AppColors.resolve(AppColors.slateMuted, context)),
            ),
          ],
        ],
      ),
    );
  }
}
