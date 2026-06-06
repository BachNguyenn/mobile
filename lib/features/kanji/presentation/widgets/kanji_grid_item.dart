import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/kanji/domain/entities/kanji_card.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:mobile/shared/widgets/jlpt_level_badge.dart';

class KanjiGridItem extends StatefulWidget {
  final KanjiCard kanji;

  const KanjiGridItem({super.key, required this.kanji});

  @override
  State<KanjiGridItem> createState() => _KanjiGridItemState();
}

class _KanjiGridItemState extends State<KanjiGridItem> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final kanji = widget.kanji;
    final meanings = kanji.meanings
        .split(',')
        .map((meaning) => meaning.trim())
        .where((meaning) => meaning.isNotEmpty)
        .toList();
    final primaryMeaning = meanings.isEmpty ? 'Chưa có nghĩa' : meanings.first;
    final primaryReading = kanji.kunyomi.trim().isNotEmpty
        ? kanji.kunyomi.trim()
        : kanji.onyomi.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showInfo = !_showInfo),
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.sp12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
            border: Border.all(
              color: AppColors.resolve(AppColors.slateLight, context).withValues(alpha: 0.30),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: JlptLevelBadge(
                  level: kanji.jlptLevel,
                  color: AppColors.leafGreen,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: _DetailButton(kanji: kanji),
              ),
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _showInfo
                      ? _KanjiInfoFace(
                          key: const ValueKey('info'),
                          meaning: primaryMeaning,
                          reading: primaryReading,
                        )
                      : _KanjiCharacterFace(
                          key: const ValueKey('kanji'),
                          kanji: kanji.kanji,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KanjiCharacterFace extends StatelessWidget {
  final String kanji;

  const _KanjiCharacterFace({super.key, required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          kanji,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.kanjiDisplay.copyWith(
            color: AppColors.resolve(AppColors.navyDark, context),
            fontSize: 46,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.touch_app_rounded,
              size: 14,
              color: AppColors.resolve(AppColors.leafGreen, context),
            ),
            const SizedBox(width: AppSpacing.sp4),
            Text(
              'xem nghĩa',
              style: AppTypography.labelS.copyWith(
                color: AppColors.resolve(AppColors.leafGreen, context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KanjiInfoFace extends StatelessWidget {
  final String meaning;
  final String reading;

  const _KanjiInfoFace({
    super.key,
    required this.meaning,
    required this.reading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          meaning,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMBold.copyWith(
            color: AppColors.resolve(AppColors.leafDark, context),
            fontWeight: FontWeight.w900,
          ),
        ),
        if (reading.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sp8),
          Text(
            reading,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label.copyWith(
              color: AppColors.resolve(AppColors.slateMuted, context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailButton extends StatelessWidget {
  final KanjiCard kanji;

  const _DetailButton({required this.kanji});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Chi tiết',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KanjiDetailScreen(kanji: kanji),
            ),
          ),
          child: Ink(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.resolve(AppColors.navySoft, context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.resolve(AppColors.navy, context).withValues(alpha: 0.08)),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.resolve(AppColors.navy, context),
              size: 19,
            ),
          ),
        ),
      ),
    );
  }
}
