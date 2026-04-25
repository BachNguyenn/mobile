import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CollapsedTitle extends StatelessWidget {
  const CollapsedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '禅 · Zen Japanese',
      style: AppTypography.headingS.copyWith(
        color: AppColors.ink,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
