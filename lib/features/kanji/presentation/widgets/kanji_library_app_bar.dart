import 'package:flutter/material.dart';
import '../../../../shared/widgets/library_sliver_app_bar.dart';

class KanjiLibraryAppBar extends StatelessWidget {
  const KanjiLibraryAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const LibrarySliverAppBar(
      title: 'Thư viện Chữ Hán',
      heroTag: 'kanji_card',
    );
  }
}
