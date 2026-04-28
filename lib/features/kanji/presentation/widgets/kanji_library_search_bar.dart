import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/kanji_library_provider.dart';

class KanjiLibrarySearchBar extends ConsumerWidget {
  const KanjiLibrarySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp16,
        AppSpacing.sp8,
        AppSpacing.sp16,
        AppSpacing.sp8,
      ),
      child: TextField(
        onChanged: (value) =>
            ref.read(kanjiSearchQueryProvider.notifier).state = value,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo Hán tự, nghĩa hoặc cách đọc...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.mossGreen,
          ),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            borderSide: BorderSide(
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusS),
            borderSide: const BorderSide(
              color: AppColors.mossGreen,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
