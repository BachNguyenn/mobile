import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class AnalyticsHeatmap extends StatelessWidget {
  final Map<DateTime, int> heatmapData;

  const AnalyticsHeatmap({super.key, required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    // 15 columns (weeks), 7 rows (days: Mon-Sun)
    const int columns = 15;
    const int rows = 7;
    final now = DateTime.now();
    final todayNormalized = DateTime(now.year, now.month, now.day);
    final currentWeekday = now.weekday; // 1 (Mon) to 7 (Sun)

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(rows, (index) {
                  // Only show label for Mon, Wed, Fri
                  final isLabel = index == 0 || index == 2 || index == 4;
                  return Container(
                    height: 14,
                    margin: const EdgeInsets.only(bottom: 4),
                    alignment: Alignment.centerRight,
                    child: Text(
                      isLabel ? _getDayLabel(index) : '',
                      style: AppTypography.labelS.copyWith(
                        color: AppColors.slateMuted,
                        fontSize: 10,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: AppSpacing.sp8),
              // Heatmap Grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Cell size based on available width
                    final cellSize =
                        (constraints.maxWidth - (columns - 1) * 4) / columns;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(columns, (colIndex) {
                        return Column(
                          children: List.generate(rows, (rowIndex) {
                            final offset =
                                (columns - 1 - colIndex) * 7 +
                                (currentWeekday - 1 - rowIndex);

                            final bool isFuture = offset < 0;
                            int count = 0;

                            if (!isFuture) {
                              final date = todayNormalized.subtract(
                                Duration(days: offset),
                              );
                              count = heatmapData[date] ?? 0;
                            }

                            return Container(
                              width: cellSize,
                              height: cellSize,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: isFuture
                                    ? Colors.transparent
                                    : _getColorForCount(count, context),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        );
                      }),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Ít',
                style: AppTypography.labelS.copyWith(
                  color: AppColors.slateMuted,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 4),
              const _LegendBox(count: 0),
              const SizedBox(width: 2),
              const _LegendBox(count: 5),
              const SizedBox(width: 2),
              const _LegendBox(count: 15),
              const SizedBox(width: 2),
              const _LegendBox(count: 25),
              const SizedBox(width: 2),
              const _LegendBox(count: 35),
              const SizedBox(width: 4),
              Text(
                'Nhiều',
                style: AppTypography.labelS.copyWith(
                  color: AppColors.slateMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int index) {
    switch (index) {
      case 0:
        return 'T2';
      case 2:
        return 'T4';
      case 4:
        return 'T6';
      default:
        return '';
    }
  }

  Color _getColorForCount(int count, BuildContext context) {
    if (count == 0) return AppColors.resolve(AppColors.creamDark, context);
    final baseColor = AppColors.resolve(AppColors.mossGreen, context);
    if (count < 10) return baseColor.withValues(alpha: 0.3);
    if (count < 20) return baseColor.withValues(alpha: 0.6);
    if (count < 30) return baseColor.withValues(alpha: 0.85);
    return baseColor;
  }
}

class _LegendBox extends StatelessWidget {
  final int count;

  const _LegendBox({required this.count});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (count == 0) {
      color = AppColors.resolve(AppColors.creamDark, context);
    } else {
      final baseColor = AppColors.resolve(AppColors.mossGreen, context);
      if (count < 10) {
        color = baseColor.withValues(alpha: 0.3);
      } else if (count < 20) {
        color = baseColor.withValues(alpha: 0.6);
      } else if (count < 30) {
        color = baseColor.withValues(alpha: 0.85);
      } else {
        color = baseColor;
      }
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
