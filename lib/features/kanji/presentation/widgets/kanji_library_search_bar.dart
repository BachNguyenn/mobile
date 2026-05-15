import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/kanji_library_provider.dart';

class KanjiLibrarySearchBar extends ConsumerStatefulWidget {
  const KanjiLibrarySearchBar({super.key});

  @override
  ConsumerState<KanjiLibrarySearchBar> createState() =>
      _KanjiLibrarySearchBarState();
}

class _KanjiLibrarySearchBarState extends ConsumerState<KanjiLibrarySearchBar> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      ref.read(kanjiSearchQueryProvider.notifier).state = value.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sp16,
        AppSpacing.sp8,
        AppSpacing.sp16,
        AppSpacing.sp8,
      ),
      child: TextField(
        onChanged: _onChanged,
        style: AppTypography.bodyM.copyWith(
          color: AppColors.navyDark,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm Hán tự, nghĩa hoặc cách đọc...',
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
            borderSide: const BorderSide(
              color: AppColors.leafGreen,
              width: 1.4,
            ),
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
