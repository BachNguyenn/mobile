import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'kanji_jlpt_filter_dialog.dart';

class KanjiLibraryAppBar extends StatelessWidget {
  const KanjiLibraryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
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
              'Thư viện Chữ Hán',
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
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const KanjiJlptFilterDialog(),
          ),
        ),
      ],
    );
  }
}
