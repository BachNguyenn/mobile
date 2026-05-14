import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Card lớn cho menu học tập trên Home screen
///
/// Premium redesign: gradient accent stripe, gradient icon container,
/// animated arrow indicator, and gradient progress bar.
class LearningCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String badge;
  final String metricLabel;
  final String metricValue;
  final List<String> highlights;
  final IconData icon;
  final double progress;
  final String heroTag;
  final Color accentColor;
  final VoidCallback onTap;

  const LearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.metricLabel,
    required this.metricValue,
    required this.highlights,
    required this.icon,
    required this.progress,
    required this.heroTag,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<LearningCard> createState() => _LearningCardState();
}

class _LearningCardState extends State<LearningCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
    _arrowAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress * 100).toInt();

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.learningCardHeight,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.slateLight.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: widget.accentColor.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Left accent gradient stripe ──────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.accentColor,
                      widget.accentColor.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusM),
                    bottomLeft: Radius.circular(AppSpacing.radiusM),
                  ),
                ),
              ),

              // ── Card content ────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sp16,
                    AppSpacing.sp16,
                    AppSpacing.sp20,
                    AppSpacing.sp16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: AppSpacing.iconContainerSize,
                            height: AppSpacing.iconContainerSize,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.accentColor.withValues(alpha: 0.12),
                                  widget.accentColor.withValues(alpha: 0.06),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusS,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 24,
                              color: widget.accentColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _InfoBadge(
                                  label: widget.badge,
                                  color: widget.accentColor,
                                ),
                                const SizedBox(height: AppSpacing.sp8),
                                Text(
                                  widget.title,
                                  style: AppTypography.headingS,
                                ),
                                const SizedBox(height: AppSpacing.sp4),
                                Text(
                                  widget.subtitle,
                                  style: AppTypography.caption,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$percentage%',
                                style: AppTypography.statNumber.copyWith(
                                  color: widget.accentColor,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedBuilder(
                                animation: _arrowAnim,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_arrowAnim.value, 0),
                                    child: child,
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: widget.accentColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: AppSpacing.sp8,
                              runSpacing: AppSpacing.sp8,
                              children: [
                                for (final item in widget.highlights.take(2))
                                  _HighlightChip(
                                    label: item,
                                    color: widget.accentColor,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                widget.metricLabel,
                                style: AppTypography.label,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.metricValue,
                                style: AppTypography.bodyMBold.copyWith(
                                  color: widget.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sp12),
                      _GradientAccentBar(
                        progress: widget.progress,
                        color: widget.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: AppTypography.labelS.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HighlightChip extends StatelessWidget {
  final String label;
  final Color color;

  const _HighlightChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp8,
        vertical: AppSpacing.sp4,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamDark.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Gradient progress bar with dot indicator
class _GradientAccentBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _GradientAccentBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final clampedValue = value.clamp(0.0, 1.0);
        return SizedBox(
          height: AppSpacing.progressBarHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fillWidth = constraints.maxWidth * clampedValue;
              return Stack(
                children: [
                  // Track
                  Container(
                    height: AppSpacing.progressBarHeight,
                    decoration: BoxDecoration(
                      color: AppColors.creamDark,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.progressBarHeight / 2,
                      ),
                    ),
                  ),
                  // Fill
                  if (fillWidth > 0)
                    Container(
                      width: fillWidth,
                      height: AppSpacing.progressBarHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withValues(alpha: 0.6)],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.progressBarHeight / 2,
                        ),
                      ),
                    ),
                  // Leading dot
                  if (fillWidth > 3)
                    Positioned(
                      left: fillWidth - 3,
                      top: 0,
                      child: Container(
                        width: AppSpacing.progressBarHeight,
                        height: AppSpacing.progressBarHeight,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
