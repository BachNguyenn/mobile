import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/grammar/application/providers/grammar_library_provider.dart';
import '../../features/kanji/application/providers/kanji_library_provider.dart';
import '../../features/vocabulary/application/providers/vocabulary_library_provider.dart';

/// Global Search Delegate — tìm kiếm xuyên suốt Kanji, Từ vựng, Ngữ pháp
///
/// Sử dụng SearchDelegate với Japandi styling.
/// Tận dụng FTS5 đã có trong database cho Kanji search.
class GlobalSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  GlobalSearchDelegate(this.ref)
    : super(
        searchFieldLabel: 'Tìm Kanji, từ vựng, ngữ pháp...',
        searchFieldStyle: AppTypography.bodyM.copyWith(
          color: AppColors.slateGrey,
        ),
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp16,
          vertical: AppSpacing.sp12,
        ),
        hintStyle: AppTypography.bodyM.copyWith(
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded, color: AppColors.slateMuted),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slateGrey),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (!_shouldSearch(query)) {
      return _buildShortQueryState(context);
    }
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(context);
    }
    if (!_shouldSearch(query)) {
      return _buildShortQueryState(context);
    }
    return _buildSearchResults(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sp16),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: AppTypography.bodyM.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: AppSpacing.sp8),
            const Text(
              'Hỗ trợ tìm theo Hán tự, nghĩa, hoặc cách đọc',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortQueryState(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Text(
          'Nhập thêm ký tự để tìm nhanh hơn',
          style: AppTypography.bodyM.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
        ),
      ),
    );
  }

  bool _shouldSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.length >= 2) return true;
    return RegExp(r'[\u3040-\u30ff\u3400-\u9fff]').hasMatch(trimmed);
  }

  Widget _buildSearchResults(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Consumer(
        builder: (context, ref, _) {
          final results = ref.watch(kanjiSearchResultsProvider(query));
          final vocabularyResults = ref.watch(
            vocabularySearchResultsProvider(query),
          );
          final grammarResults = ref.watch(grammarSearchResultsProvider(query));

          return results.when(
            data: (kanjis) {
              final vocabulary = vocabularyResults.value ?? [];
              final grammar = grammarResults.value ?? [];

              if (kanjis.isEmpty && vocabulary.isEmpty && grammar.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.slateLight,
                      ),
                      const SizedBox(height: AppSpacing.sp12),
                      Text(
                        'Không tìm thấy kết quả cho "$query"',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.slateMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final resolvedMossGreen = AppColors.resolve(AppColors.mossGreen, context);

              return ListView(
                padding: AppSpacing.paddingAll16,
                children: [
                  // Section header: Kanji
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSpacing.sp12,
                      top: AppSpacing.sp8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp12,
                            vertical: AppSpacing.sp4,
                          ),
                          decoration: BoxDecoration(
                            color: resolvedMossGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusXS,
                            ),
                          ),
                          child: Text(
                            'Chữ Hán (${kanjis.length})',
                            style: AppTypography.label.copyWith(
                              color: resolvedMossGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kanji results
                  ...kanjis
                      .take(20)
                      .map((kanji) => _buildKanjiResultTile(context, kanji)),

                  if (vocabulary.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sp24),
                    _buildSectionHeader(
                      'Từ vựng (${vocabulary.length})',
                      AppColors.waterBlue,
                    ),
                    ...vocabulary
                        .take(10)
                        .map(
                          (item) => _buildSimpleResultTile(
                            context,
                            icon: Icons.menu_book_rounded,
                            title: item.word,
                            subtitle: '${item.reading} • ${item.meaning}',
                            color: AppColors.waterBlue,
                            jlptLevel: item.jlptLevel,
                          ),
                        ),
                  ],
                  if (grammar.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sp24),
                    _buildSectionHeader(
                      'Ngữ pháp (${grammar.length})',
                      AppColors.sunGold,
                    ),
                    ...grammar
                        .take(10)
                        .map(
                          (item) => _buildSimpleResultTile(
                            context,
                            icon: Icons.edit_note_rounded,
                            title: item.title,
                            subtitle: item.shortExplanation,
                            color: AppColors.sunGold,
                            jlptLevel: item.jlptLevel,
                          ),
                        ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.mossGreen),
            ),
            error: (err, _) =>
                Center(child: Text('Lỗi: $err', style: AppTypography.bodyM)),
          );
        },
      ),
    );
  }

  Widget _buildKanjiResultTile(BuildContext context, dynamic kanji) {
    final resolvedSlateLight = AppColors.resolve(AppColors.slateLight, context);
    final resolvedMossLight = AppColors.resolve(AppColors.mossLight, context);
    final resolvedMossDark = AppColors.resolve(AppColors.mossDark, context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp8),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(color: resolvedSlateLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Kanji character
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.resolve(AppColors.creamDark, context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
            ),
            child: Center(
              child: Text(
                kanji.kanji,
                style: AppTypography.kanjiDisplay.copyWith(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sp16),

          // Meanings + readings
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kanji.meanings,
                  style: AppTypography.bodyMBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  '${kanji.onyomi} / ${kanji.kunyomi}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // JLPT badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sp8,
              vertical: AppSpacing.sp4,
            ),
            decoration: BoxDecoration(
              color: resolvedMossLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
            ),
            child: Text(
              'N${kanji.jlptLevel}',
              style: AppTypography.labelS.copyWith(
                color: resolvedMossDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sp12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp12,
            vertical: AppSpacing.sp4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
          ),
          child: Text(
            title,
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleResultTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int jlptLevel,
  }) {
    final resolvedSlateLight = AppColors.resolve(AppColors.slateLight, context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp8),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(color: resolvedSlateLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            'N$jlptLevel',
            style: AppTypography.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
