import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/vocabulary_library_provider.dart';

class VocabularySearchBar extends ConsumerWidget {
  const VocabularySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) =>
          ref.read(vocabularySearchQueryProvider.notifier).state = value,
      style: AppTypography.bodyM.copyWith(
        color: AppColors.navyDark,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: 'Tìm từ, cách đọc hoặc nghĩa...',
        hintStyle: AppTypography.bodyS.copyWith(color: AppColors.slateMuted),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColors.leafGreen,
        ),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: BorderSide(
            color: AppColors.slateLight.withValues(alpha: 0.32),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
          borderSide: const BorderSide(color: AppColors.leafGreen, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sp16,
          vertical: AppSpacing.sp16,
        ),
      ),
    );
  }
}
