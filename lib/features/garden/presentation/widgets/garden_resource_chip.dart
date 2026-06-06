import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_typography.dart';

/// Resource chip for the garden app bar.
class GardenResourceChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const GardenResourceChip({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = AppColors.resolve(color, context);
    final resolvedGlassBg = AppColors.resolve(AppColors.glassBg, context);
    final resolvedGlassShadow = AppColors.resolve(AppColors.glassShadow, context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: resolvedGlassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: resolvedColor.withValues(alpha: 0.2)),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: resolvedColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(color: resolvedGlassShadow, blurRadius: 4),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: resolvedColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: AppTypography.label.copyWith(
              color: resolvedColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
