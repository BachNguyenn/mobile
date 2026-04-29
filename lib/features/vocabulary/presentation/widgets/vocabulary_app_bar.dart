import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/library_sliver_app_bar.dart';

class VocabularyAppBar extends StatelessWidget {
  const VocabularyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const LibrarySliverAppBar(
      title: 'Thư viện Từ vựng',
      color: AppColors.waterBlue,
      heroTag: 'vocab_card',
    );
  }
}
