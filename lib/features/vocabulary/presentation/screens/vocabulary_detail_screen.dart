import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';

class VocabularyDetailScreen extends ConsumerWidget {
  final Vocabulary vocabulary;

  const VocabularyDetailScreen({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final resolvedWaterBlue = AppColors.resolve(AppColors.waterBlue, context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chi tiết từ vựng',
          style: AppTypography.headingS.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Phát âm',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => _speak(context, ref),
            style: IconButton.styleFrom(
              backgroundColor: resolvedWaterBlue.withValues(alpha: 0.10),
              foregroundColor: resolvedWaterBlue,
            ),
          ),
          const SizedBox(width: AppSpacing.sp8),
        ],
      ),
      body: AppPageBackground(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp12,
            AppSpacing.sp16,
            AppSpacing.sp32,
          ),
          children: [
            _HeroCard(
              vocabulary: vocabulary,
              onSpeak: () => _speak(context, ref),
            ),
            const SizedBox(height: AppSpacing.sp16),
            if (_hasMetadata) ...[
              Wrap(
                spacing: AppSpacing.sp8,
                runSpacing: AppSpacing.sp8,
                children: [
                  if (vocabulary.partOfSpeech?.isNotEmpty ?? false)
                    _MetaPill(vocabulary.partOfSpeech!),
                  if (vocabulary.pitchAccent?.isNotEmpty ?? false)
                    _MetaPill('Pitch: ${vocabulary.pitchAccent}'),
                  JlptLevelBadge(
                    level: vocabulary.jlptLevel,
                    color: AppColors.waterBlue,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp16),
            ],
            if (vocabulary.imageUrl?.isNotEmpty ?? false) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                child: Image.network(
                  vocabulary.imageUrl!,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: AppSpacing.sp16),
            ],
            _InfoCard(
              title: 'Nghĩa',
              icon: Icons.translate_rounded,
              color: AppColors.waterBlue,
              child: Text(
                vocabulary.meaning,
                style: AppTypography.bodyL.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (vocabulary.exampleSentences.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp16),
              _InfoCard(
                title: 'Câu ví dụ',
                icon: Icons.subject_rounded,
                color: AppColors.terracotta,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final example in vocabulary.exampleSentences)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
                        child: _ExampleBlock(example: example),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasMetadata =>
      (vocabulary.partOfSpeech?.isNotEmpty ?? false) ||
      (vocabulary.pitchAccent?.isNotEmpty ?? false) ||
      vocabulary.jlptLevel > 0;

  Future<void> _speak(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(audioServiceProvider).speakJapanese(vocabulary.word);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể phát âm thanh trên thiết bị này.'),
        ),
      );
    }
  }
}

class _HeroCard extends StatelessWidget {
  final Vocabulary vocabulary;
  final VoidCallback onSpeak;

  const _HeroCard({required this.vocabulary, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedWaterBlue = AppColors.resolve(AppColors.waterBlue, context);

    return AppCard(
      borderColor: resolvedWaterBlue.withValues(alpha: 0.16),
      shadowColor: resolvedWaterBlue.withValues(alpha: 0.05),
      child: Column(
        children: [
          Text(
            vocabulary.word,
            textAlign: TextAlign.center,
            style: AppTypography.kanjiHero.copyWith(
              color: theme.colorScheme.onSurface,
              fontSize: 56,
            ),
          ),
          if (vocabulary.reading.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              vocabulary.reading,
              textAlign: TextAlign.center,
              style: AppTypography.bodyL.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sp16),
          IconButton.filledTonal(
            tooltip: 'Phát âm',
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded),
            style: IconButton.styleFrom(
              backgroundColor: resolvedWaterBlue.withValues(alpha: 0.10),
              foregroundColor: resolvedWaterBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;

  const _MetaPill(this.label);

  @override
  Widget build(BuildContext context) {
    final resolvedWaterBlue = AppColors.resolve(AppColors.waterBlue, context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: resolvedWaterBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: resolvedWaterBlue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    return AppCard(
      borderColor: resolvedColor.withValues(alpha: 0.14),
      shadowColor: resolvedColor.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: resolvedColor, size: 18),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                title,
                style: AppTypography.bodyMBold.copyWith(
                  color: resolvedColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          child,
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final VocabularyExample example;

  const _ExampleBlock({required this.example});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedNavySoft = AppColors.resolve(AppColors.navySoft, context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp12),
      decoration: BoxDecoration(
        color: resolvedNavySoft.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.text,
            style: AppTypography.bodyL.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (example.reading.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(example.reading, style: AppTypography.caption),
          ],
          if (example.meaning.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp4),
            Text(
              example.meaning,
              style: AppTypography.bodyM.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
