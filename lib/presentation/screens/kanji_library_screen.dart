import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';
import 'kanji_detail_screen.dart';

/// Thư viện Kanji — redesigned với Japandi palette
///
/// Thay đổi so với bản cũ:
/// - Color scheme dùng AppColors thay vì hardcode
/// - Hero animation support (tag: 'kanji_card')
/// - Spacing theo quy tắc 8dp
class KanjiLibraryScreen extends ConsumerWidget {
  const KanjiLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(kanjiSearchResultsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.mossGreen,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'kanji_card',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Thư viện Kanji',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.mossGradient,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: AppColors.white),
                onPressed: () => _showFilterDialog(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingAll16,
              child: TextField(
                onChanged: (value) => ref.read(kanjiSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo Hán tự, nghĩa hoặc cách đọc...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.mossGreen),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide(color: AppColors.slateLight.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          searchResults.when(
            data: (kanjis) {
              if (kanjis.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
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
                          'Không tìm thấy chữ Kanji nào.',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: AppSpacing.sp12,
                    crossAxisSpacing: AppSpacing.sp12,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final kanji = kanjis[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KanjiDetailScreen(kanji: kanji),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                            border: Border.all(
                              color: AppColors.slateLight.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.ink.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                kanji.kanji,
                                style: AppTypography.kanjiDisplay.copyWith(
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sp4),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sp4,
                                ),
                                child: Text(
                                  kanji.meanings.split(',').first,
                                  style: AppTypography.labelS.copyWith(
                                    color: AppColors.slateMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: kanjis.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.mossGreen),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('Lỗi: $err', style: AppTypography.bodyM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        ),
        title: Text('Lọc theo trình độ JLPT', style: AppTypography.headingS),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFilterOption(context, ref, null, 'Tất cả'),
            _buildFilterOption(context, ref, 5, 'N5'),
            _buildFilterOption(context, ref, 4, 'N4'),
            _buildFilterOption(context, ref, 3, 'N3'),
            _buildFilterOption(context, ref, 2, 'N2'),
            _buildFilterOption(context, ref, 1, 'N1'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, WidgetRef ref, int? level, String label) {
    final currentFilter = ref.watch(kanjiJlptFilterProvider);
    return ListTile(
      title: Text(label, style: AppTypography.bodyM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
      ),
      trailing: currentFilter == level
          ? const Icon(Icons.check_rounded, color: AppColors.mossGreen)
          : null,
      onTap: () {
        ref.read(kanjiJlptFilterProvider.notifier).state = level;
        Navigator.pop(context);
      },
    );
  }
}
