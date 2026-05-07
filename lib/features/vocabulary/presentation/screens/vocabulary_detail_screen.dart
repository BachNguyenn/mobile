import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/vocabulary/domain/entities/vocabulary.dart';

class VocabularyDetailScreen extends ConsumerWidget {
  final Vocabulary vocabulary;

  const VocabularyDetailScreen({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.waterBlue,
        foregroundColor: AppColors.white,
        title: Text(
          vocabulary.word,
          style: AppTypography.headingS.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            tooltip: 'Phat am',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => _speak(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.sp24),
        children: [
          _HeroCard(
            vocabulary: vocabulary,
            onSpeak: () => _speak(context, ref),
          ),
          const SizedBox(height: AppSpacing.sp20),
          if (_hasMetadata) ...[
            Wrap(
              spacing: AppSpacing.sp8,
              runSpacing: AppSpacing.sp8,
              children: [
                if (vocabulary.partOfSpeech?.isNotEmpty ?? false)
                  _MetaPill(vocabulary.partOfSpeech!),
                if (vocabulary.pitchAccent?.isNotEmpty ?? false)
                  _MetaPill('Pitch: ${vocabulary.pitchAccent}'),
                _MetaPill('N${vocabulary.jlptLevel}'),
              ],
            ),
            const SizedBox(height: AppSpacing.sp20),
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
            const SizedBox(height: AppSpacing.sp20),
          ],
          _InfoCard(
            title: 'Meaning',
            icon: Icons.translate_rounded,
            color: AppColors.waterBlue,
            child: Text(
              vocabulary.meaning,
              style: AppTypography.bodyL.copyWith(color: AppColors.ink),
            ),
          ),
          if (vocabulary.exampleSentences.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp16),
            _InfoCard(
              title: 'Example sentences',
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
          const SizedBox(height: AppSpacing.sp32),
        ],
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
          content: Text('Khong the phat am thanh tren thiet bi nay.'),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp24),
      decoration: BoxDecoration(
        color: AppColors.waterBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: AppColors.waterBlue.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          Text(
            vocabulary.word,
            textAlign: TextAlign.center,
            style: AppTypography.kanjiHero.copyWith(
              color: AppColors.ink,
              fontSize: 56,
            ),
          ),
          if (vocabulary.reading.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              vocabulary.reading,
              textAlign: TextAlign.center,
              style: AppTypography.bodyL.copyWith(color: AppColors.slateGrey),
            ),
          ],
          const SizedBox(height: AppSpacing.sp12),
          IconButton.filledTonal(
            tooltip: 'Phat am',
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded),
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.waterBlue.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: AppColors.waterBlue),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sp20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                title,
                style: AppTypography.bodyMBold.copyWith(color: color),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          example.text,
          style: AppTypography.bodyL.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (example.reading.isNotEmpty)
          Text(example.reading, style: AppTypography.caption),
        if (example.meaning.isNotEmpty)
          Text(
            example.meaning,
            style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
          ),
      ],
    );
  }
}
