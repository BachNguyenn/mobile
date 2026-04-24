import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';

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
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp16,
          vertical: AppSpacing.sp12,
        ),
        hintStyle: AppTypography.bodyM.copyWith(
          color: AppColors.slateMuted,
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
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState();
    }
    return _buildSearchResults();
  }

  Widget _buildEmptyState() {
    return Container(
      color: AppColors.cream,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: AppColors.slateLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.sp16),
            Text(
              'Nhập từ khóa để tìm kiếm',
              style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
            ),
            const SizedBox(height: AppSpacing.sp8),
            Text(
              'Hỗ trợ tìm theo Hán tự, nghĩa, hoặc cách đọc',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: AppColors.cream,
      child: Consumer(
        builder: (context, ref, _) {
          // Update search query in provider
          Future.microtask(() {
            ref.read(kanjiSearchQueryProvider.notifier).state = query;
          });

          final results = ref.watch(kanjiSearchResultsProvider);

          return results.when(
            data: (kanjis) {
              if (kanjis.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
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
                            color: AppColors.mossGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
                          ),
                          child: Text(
                            'Chữ Hán (${kanjis.length})',
                            style: AppTypography.label.copyWith(
                              color: AppColors.mossGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kanji results
                  ...kanjis.take(20).map((kanji) => _buildKanjiResultTile(kanji)),

                  // Placeholder sections cho Từ vựng & Ngữ pháp
                  const SizedBox(height: AppSpacing.sp24),
                  _buildPlaceholderSection('Từ vựng', Icons.menu_book_rounded),
                  const SizedBox(height: AppSpacing.sp16),
                  _buildPlaceholderSection('Ngữ pháp', Icons.edit_note_rounded),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.mossGreen),
            ),
            error: (err, _) => Center(
              child: Text('Lỗi: $err', style: AppTypography.bodyM),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanjiResultTile(dynamic kanji) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sp8),
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(
          color: AppColors.slateLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Kanji character
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.creamDark,
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
              color: AppColors.mossLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
            ),
            child: Text(
              'N${kanji.jlptLevel}',
              style: AppTypography.labelS.copyWith(
                color: AppColors.mossDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderSection(String title, IconData icon) {
    return Container(
      padding: AppSpacing.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.creamDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        border: Border.all(
          color: AppColors.slateLight.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.slateMuted),
          const SizedBox(width: AppSpacing.sp12),
          Text(
            '$title — Sắp ra mắt',
            style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
          ),
        ],
      ),
    );
  }
}
