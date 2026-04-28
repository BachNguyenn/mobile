import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../global_search_delegate.dart';
import '../../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../screens/learning_path_screen.dart';
import '../../../features/grammar/presentation/screens/grammar_analysis_screen.dart';

typedef TabSwitchCallback = void Function(int index);

class QuickActionChips extends StatelessWidget {
  final WidgetRef ref;
  final BuildContext context;
  final TabSwitchCallback? onSwitchTab;

  const QuickActionChips({
    super.key,
    required this.ref,
    required this.context,
    this.onSwitchTab,
  });

  @override
  Widget build(BuildContext outerContext) {
    final chips = [
      _ChipData(
        icon: Icons.add_circle_outline_rounded,
        label: 'Bài mới',
        color: AppColors.mossGreen,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LearningPathScreen()),
          );
        },
      ),
      _ChipData(
        icon: Icons.bar_chart_rounded,
        label: 'Thống kê',
        color: AppColors.sunGold,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          );
        },
      ),
      _ChipData(
        icon: Icons.psychology_rounded,
        label: 'Phân tích AI',
        color: Colors.purple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GrammarAnalysisScreen()),
          );
        },
      ),
      _ChipData(
        icon: Icons.search_rounded,
        label: 'Tra cứu',
        color: AppColors.slateGrey,
        onTap: () {
          showSearch(context: context, delegate: GlobalSearchDelegate(ref));
        },
      ),
    ];

    return SizedBox(
      height: AppSpacing.quickActionChipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingH24,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sp12),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return _ActionChip(data: chip);
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final _ChipData data;

  const _ActionChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            border: Border.all(
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 18, color: data.color),
              const SizedBox(width: AppSpacing.sp8),
              Text(
                data.label,
                style: AppTypography.label.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ChipData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
