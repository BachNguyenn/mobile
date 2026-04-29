import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class LibrarySliverAppBar extends StatelessWidget {
  final String title;
  final Color color;
  final String? heroTag;
  final List<Widget> actions;

  const LibrarySliverAppBar({
    super.key,
    required this.title,
    required this.color,
    this.heroTag,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: color,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      title: _buildTitle(),
      centerTitle: true,
      actions: actions,
    );
  }

  Widget _buildTitle() {
    return Material(
      color: Colors.transparent,
      child: Text(
        title,
        style: AppTypography.headingS.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}
