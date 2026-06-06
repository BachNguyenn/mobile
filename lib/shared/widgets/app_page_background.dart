import 'package:flutter/cupertino.dart';
import '../../core/theme/app_colors.dart';

class AppPageBackground extends StatelessWidget {
  final Widget child;

  const AppPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.pageGradient.colors.map((color) {
      if (color is CupertinoDynamicColor) {
        return CupertinoDynamicColor.resolve(color, context);
      }
      return color;
    }).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: AppColors.pageGradient.begin,
          end: AppColors.pageGradient.end,
        ),
      ),
      child: child,
    );
  }
}
