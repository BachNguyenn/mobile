import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/audio_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/presentation/providers/grammar_library_provider.dart';
import 'package:mobile/features/kanji/presentation/providers/kanji_library_provider.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_detail_screen.dart';
import 'package:mobile/features/review/domain/entities/review_item.dart';
import 'package:mobile/features/sentence/domain/entities/sentence.dart';
import 'package:mobile/features/sentence/presentation/providers/sentence_provider.dart';
import 'package:mobile/features/vocabulary/presentation/providers/vocabulary_library_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Tra cuu', style: AppTypography.headingM),
        backgroundColor: AppColors.cream.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.slateGrey,
        elevation: 0,
      ),
      body: AppPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.sp16),
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                hintText: 'Kanji, từ vựng, ngữ pháp, câu ví dụ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp16),
            _AsyncSection(
              title: 'Chữ Hán',
              color: AppColors.mossGreen,
              value: kanjiResults,
              itemBuilder: (kanji) => _DictionaryTile(
                icon: Icons.translate_rounded,
                color: AppColors.mossGreen,
                title: kanji.kanji,
                subtitle: _joinPreview([
                  kanji.meanings,
                  '${kanji.onyomi} / ${kanji.kunyomi}',
                  if (kanji.radicals.isNotEmpty)
                    'Radicals: ${kanji.radicals.take(3).join(', ')}',
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
              color: AppColors.sunGold,
              value: grammarResults,
              itemBuilder: (grammar) => _DictionaryTile(
                icon: Icons.edit_note_rounded,
                color: AppColors.sunGold,
                title: grammar.title,
                subtitle: grammar.shortExplanation,
                trailing: 'On tap',
                onTap: () {
                  Navigator.push(
                    context,
                    AppRoutes.review([ReviewItem.fromGrammar(grammar)]),
                  );
                },
              ),
            ),
            _AsyncSection<Sentence>(
              title: 'Câu ví dụ',
              color: AppColors.terracotta,
              value: sentenceResults,
              itemBuilder: (sentence) => _DictionaryTile(
                icon: Icons.subject_rounded,
                color: AppColors.terracotta,
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
        ),
      ),
    );
  }

  String _joinPreview(List<String> parts) {
    return parts.where((part) => part.trim().isNotEmpty).join(' - ');
  }
}

class _AsyncSection<T> extends StatelessWidget {
  final String title;
  final Color color;
  final AsyncValue<List<T>> value;
  final Widget Function(T item) itemBuilder;

  const _AsyncSection({
    required this.title,
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
              _SectionHeader(title: '$title (${items.length})', color: color),
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
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.bodyMBold.copyWith(color: color));
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp8),
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        side: BorderSide(color: color.withValues(alpha: 0.14)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (speakText != null)
              GestureDetector(
                onTap: () async {
                  try {
                    await ref
                        .read(audioServiceProvider)
                        .speakJapanese(speakText!);
                  } catch (_) {}
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 20,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
              ),
            Text(
              trailing,
              style: AppTypography.labelS.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
