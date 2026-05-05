import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';

/// SliverAppBar dùng chung cho các Library screens (Vocabulary, Kanji, Grammar).
///
/// Sử dụng theme-aware colors thay vì hardcode, đảm bảo nhất quán
/// giữa light mode và dark mode.
class LibrarySliverAppBar extends StatelessWidget {
  final String title;
  final String? heroTag;
  final List<Widget> actions;

  const LibrarySliverAppBar({
    super.key,
    required this.title,
    this.heroTag,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      foregroundColor: theme.colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      title: _buildTitle(theme),
      centerTitle: true,
      actions: actions,
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: Text(
        title,
        style: AppTypography.headingS.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
