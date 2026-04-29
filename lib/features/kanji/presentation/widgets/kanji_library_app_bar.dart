import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/library_sliver_app_bar.dart';
import 'kanji_jlpt_filter_dialog.dart';

class KanjiLibraryAppBar extends StatelessWidget {
  const KanjiLibraryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LibrarySliverAppBar(
      title: 'Thư viện Chữ Hán',
      color: AppColors.mossGreen,
      heroTag: 'kanji_card',
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list_rounded),
          tooltip: 'Lọc JLPT',
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const KanjiJlptFilterDialog(),
          ),
        ),
      ],
    );
  }
}
