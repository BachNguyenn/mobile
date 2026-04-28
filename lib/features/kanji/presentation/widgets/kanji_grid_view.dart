import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';
import 'kanji_grid_item.dart';

class KanjiGridView extends ConsumerWidget {
  const KanjiGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(kanjiSearchResultsProvider);

    return searchResults.when(
      data: (kanjis) {
        if (kanjis.isEmpty) {
          return SliverFillRemaining(
            child: Center(
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
                    'Không tìm thấy Chữ Hán nào.',
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sp12,
              crossAxisSpacing: AppSpacing.sp12,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return KanjiGridItem(kanji: kanjis[index]);
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
    );
  }
}
