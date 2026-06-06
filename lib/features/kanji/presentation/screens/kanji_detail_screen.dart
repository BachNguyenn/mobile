import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/kanji/presentation/widgets/kanji_stroke_order_view.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';

class KanjiDetailScreen extends ConsumerWidget {
  final KanjiCard kanji;

  const KanjiDetailScreen({super.key, required this.kanji});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Chi tiết chữ Hán',
          style: AppTypography.headingS.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
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
            _KanjiHeroCard(kanji: kanji),
            const SizedBox(height: AppSpacing.sp16),
            KanjiStrokeOrderView(
              strokePaths: kanji.strokePaths,
              strokeCount: kanji.strokeCount,
            ),
            const SizedBox(height: AppSpacing.sp16),

            _InfoCard(
              title: 'Ý nghĩa',
              content: kanji.meanings,
              icon: Icons.translate_rounded,
              color: AppColors.waterBlue,
            ),
            const SizedBox(height: AppSpacing.sp16),
            Row(
              children: [
                Expanded(
                  child: _ReadingCard(
                    ref: ref,
                    title: 'Onyomi',
                    content: kanji.onyomi,
                    icon: Icons.record_voice_over_rounded,
                    color: AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: AppSpacing.sp12),
                Expanded(
                  child: _ReadingCard(
                    ref: ref,
                    title: 'Kunyomi',
                    content: kanji.kunyomi,
                    icon: Icons.record_voice_over_outlined,
                    color: AppColors.leafGreen,
                  ),
                ),
              ],
            ),
            if (kanji.radicals.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp16),
              _ListCard(
                title: 'Bộ phận',
                items: kanji.radicals,
                icon: Icons.account_tree_rounded,
                color: AppColors.sunGold,
              ),
            ],
            if (kanji.radicalNames.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp16),
              _ListCard(
                title: 'Tên bộ',
                items: kanji.radicalNames,
                icon: Icons.account_tree_outlined,
                color: AppColors.sunGold,
              ),
            ],
            if (kanji.mnemonic?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.sp16),
              _InfoCard(
                title: 'Gợi nhớ',
                content: kanji.mnemonic!,
                icon: Icons.lightbulb_rounded,
                color: AppColors.terracotta,
              ),
            ],
            if (kanji.relatedWords.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp16),
              _ListCard(
                title: 'Từ liên quan',
                items: kanji.relatedWords,
                icon: Icons.link_rounded,
                color: AppColors.waterBlue,
              ),
            ],
            if (kanji.nanori.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sp16),
              _ListCard(
                title: 'Nanori',
                items: kanji.nanori,
                icon: Icons.badge_rounded,
                color: AppColors.leafGreen,
              ),
            ],

          ],
        ),
      ),
    );
  }
}

class _KanjiHeroCard extends StatelessWidget {
  final KanjiCard kanji;

  const _KanjiHeroCard({required this.kanji});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: AppColors.brandLeafGradient,
      borderColor: AppColors.white.withValues(alpha: 0.18),
      shadowColor: AppColors.navyDark.withValues(alpha: 0.10),
      child: Column(
        children: [
          Row(
            children: [
              JlptLevelBadge(level: kanji.jlptLevel, color: AppColors.white),
              const Spacer(),
              Icon(
                Icons.brush_rounded,
                color: AppColors.white.withValues(alpha: 0.76),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp16),
          Text(
            kanji.kanji,
            style: AppTypography.kanjiHero.copyWith(
              color: AppColors.white,
              fontSize: 96,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sp8),
          Text(
            kanji.meanings,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}



class _ReadingCard extends StatelessWidget {
  final WidgetRef ref;
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _ReadingCard({
    required this.ref,
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = AppColors.resolve(color, context);

    return AppCard(
      borderColor: resolvedColor.withValues(alpha: 0.14),
      shadowColor: resolvedColor.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(icon: icon, label: title, color: resolvedColor),
          const SizedBox(height: AppSpacing.sp12),
          Row(
            children: [
              Expanded(
                child: Text(
                  content.isEmpty ? '---' : content,
                  style: AppTypography.bodyL.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (content.isNotEmpty)
                IconButton.filledTonal(
                  tooltip: 'Phát âm',
                  onPressed: () async {
                    try {
                      await ref
                          .read(audioServiceProvider)
                          .speakJapanese(content);
                    } catch (_) {}
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: resolvedColor.withValues(alpha: 0.10),
                    foregroundColor: resolvedColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedColor = AppColors.resolve(color, context);

    return AppCard(
      borderColor: resolvedColor.withValues(alpha: 0.14),
      shadowColor: resolvedColor.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(icon: icon, label: title, color: resolvedColor),
          const SizedBox(height: AppSpacing.sp12),
          Text(
            content.isEmpty ? '---' : content,
            style: AppTypography.bodyL.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _ListCard({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
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
          _CardLabel(icon: icon, label: title, color: resolvedColor),
          const SizedBox(height: AppSpacing.sp12),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: [
              for (final item in items)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sp12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: resolvedColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  ),
                  child: Text(
                    item,
                    style: AppTypography.label.copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w800,
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



class _CardLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CardLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    return Row(
      children: [
        Icon(icon, color: resolvedColor, size: 18),
        const SizedBox(width: AppSpacing.sp8),
        Text(
          label,
          style: AppTypography.bodyMBold.copyWith(
            color: resolvedColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
