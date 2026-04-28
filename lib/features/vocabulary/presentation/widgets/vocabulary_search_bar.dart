import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/vocabulary_library_provider.dart';

class VocabularySearchBar extends ConsumerWidget {
  const VocabularySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) =>
          ref.read(vocabularySearchQueryProvider.notifier).state = value,
      decoration: InputDecoration(
        hintText: 'Tìm kiếm từ vựng, nghĩa...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.waterBlue),
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
            color: AppColors.waterBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
