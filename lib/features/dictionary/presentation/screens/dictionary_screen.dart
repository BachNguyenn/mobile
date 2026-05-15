import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_library_provider.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/presentation/providers/sentence_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_library_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kanjiResults = ref.watch(kanjiSearchResultsProvider(_query));
    final vocabularyResults = ref.watch(
      vocabularySearchResultsProvider(_query),
    );
    final grammarResults = ref.watch(grammarSearchResultsProvider(_query));
    final sentenceResults = ref.watch(sentenceSearchResultsProvider(_query));
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          'Tra cứu',
          style: AppTypography.headingS.copyWith(color: AppColors.navyDark),
        ),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.slateGrey,
        elevation: 0,
      ),
      body: AppPageBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp16,
              AppSpacing.sp12,
              AppSpacing.sp16,
              AppSpacing.sp32,
            ),
            children: [
              _SearchPanel(
                controller: _controller,
                query: _query,
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
              const SizedBox(height: AppSpacing.sp16),
              if (!hasQuery)
                const AppEmptyState(
                  icon: Icons.manage_search_rounded,
                  title: 'Tìm nhanh nội dung học',
                  message: 'Nhập kanji, từ vựng, ngữ pháp hoặc câu ví dụ.',
                )
              else ...[
                _AsyncSection(
                  title: 'Chữ Hán',
                  icon: Icons.brush_rounded,
                  color: AppColors.leafGreen,
                  value: kanjiResults,
                  itemBuilder: (kanji) => _DictionaryTile(
                    icon: Icons.translate_rounded,
                    color: AppColors.leafGreen,
                    title: kanji.kanji,
                    subtitle: _joinPreview([
                      kanji.meanings,
                      '${kanji.onyomi} / ${kanji.kunyomi}',
                      if (kanji.radicals.isNotEmpty)
                        'Bộ: ${kanji.radicals.take(3).join(', ')}',
                    ]),
                    trailing: 'N${kanji.jlptLevel}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KanjiDetailScreen(kanji: kanji),
                        ),
                      );
                    },
                  ),
                ),
                _AsyncSection(
                  title: 'Từ vựng',
                  icon: Icons.style_rounded,
                  color: AppColors.waterBlue,
                  value: vocabularyResults,
                  itemBuilder: (vocabulary) => _DictionaryTile(
                    icon: Icons.menu_book_rounded,
                    color: AppColors.waterBlue,
                    title: vocabulary.word,
                    subtitle: _joinPreview([
                      vocabulary.reading,
                      vocabulary.meaning,
                      if (vocabulary.pitchAccent?.isNotEmpty ?? false)
                        'Pitch: ${vocabulary.pitchAccent}',
                    ]),
                    trailing: 'Chi tiết',
                    speakText: vocabulary.word,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.vocabularyDetail(vocabulary),
                      );
                    },
                  ),
                ),
                _AsyncSection(
                  title: 'Ngữ pháp',
                  icon: Icons.account_tree_rounded,
                  color: AppColors.terracotta,
                  value: grammarResults,
                  itemBuilder: (grammar) => _DictionaryTile(
                    icon: Icons.edit_note_rounded,
                    color: AppColors.terracotta,
                    title: grammar.title,
                    subtitle: grammar.shortExplanation,
                    trailing: 'Ôn câu',
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.grammarReview([grammar]),
                      );
                    },
                  ),
                ),
                _AsyncSection<Sentence>(
                  title: 'Câu ví dụ',
                  icon: Icons.subject_rounded,
                  color: AppColors.sunGold,
                  value: sentenceResults,
                  itemBuilder: (sentence) => _DictionaryTile(
                    icon: Icons.subject_rounded,
                    color: AppColors.sunGold,
                    title: sentence.text,
                    subtitle: sentence.meaning,
                    trailing: 'Luyện tập',
                    speakText: sentence.text,
                    onTap: () {
                      Navigator.push(
                        context,
                        AppRoutes.sentencePractice(initialSentence: sentence),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _joinPreview(List<String> parts) {
    return parts.where((part) => part.trim().isNotEmpty).join(' • ');
  }
}

class _SearchPanel extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchPanel({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.white,
      borderColor: AppColors.leafGreen.withValues(alpha: 0.16),
      shadowColor: AppColors.ink.withValues(alpha: 0.035),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        style: AppTypography.bodyM.copyWith(
          color: AppColors.navyDark,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.navySoft.withValues(alpha: 0.52),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.navy),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Xóa',
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: onClear,
                ),
          hintText: 'Kanji, từ vựng, ngữ pháp, câu ví dụ...',
          hintStyle: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: AppSpacing.sp16,
          ),
        ),
      ),
    );
  }
}

class _AsyncSection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final AsyncValue<List<T>> value;
  final Widget Function(T item) itemBuilder;

  const _AsyncSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.value,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (items) {
        final visible = items.take(8).toList();
        if (visible.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sp20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: '$title (${items.length})',
                icon: icon,
                color: color,
              ),
              const SizedBox(height: AppSpacing.sp8),
              ...visible.map(itemBuilder),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: AppSpacing.sp8),
        Text(
          title,
          style: AppTypography.bodyMBold.copyWith(
            color: AppColors.navyDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DictionaryTile extends ConsumerWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String trailing;
  final String? speakText;
  final VoidCallback onTap;

  const _DictionaryTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.speakText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.sp12),
        color: AppColors.white,
        borderColor: color.withValues(alpha: 0.14),
        shadowColor: color.withValues(alpha: 0.035),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppSpacing.radiusM),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: AppSpacing.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyMBold.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                  ],
                ],
              ),
            ),
            if (speakText != null) ...[
              const SizedBox(width: AppSpacing.sp8),
              IconButton.filledTonal(
                tooltip: 'Phát âm',
                onPressed: () async {
                  try {
                    await ref.read(audioServiceProvider).speakJapanese(
                          speakText!,
                        );
                  } catch (_) {}
                },
                icon: const Icon(Icons.volume_up_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.10),
                  foregroundColor: color,
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.sp8),
            Text(
              trailing,
              style: AppTypography.labelS.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
