import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.color,
    this.borderColor,
    this.shadowColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(AppSpacing.radiusL);
    final useThemedCardColor = color == null || color == AppColors.white;

    final resolvedColor = useThemedCardColor
        ? theme.cardColor
        : color is CupertinoDynamicColor
        ? CupertinoDynamicColor.resolve(color as CupertinoDynamicColor, context)
        : color;
    final resolvedBorderColor = borderColor is CupertinoDynamicColor
        ? CupertinoDynamicColor.resolve(
            borderColor as CupertinoDynamicColor,
            context,
          )
        : borderColor;
    final resolvedShadowColor = shadowColor is CupertinoDynamicColor
        ? CupertinoDynamicColor.resolve(
            shadowColor as CupertinoDynamicColor,
            context,
          )
        : shadowColor;

    Gradient? resolvedGradient = gradient;
    if (gradient is LinearGradient) {
      final linear = gradient as LinearGradient;
      resolvedGradient = LinearGradient(
        colors: linear.colors.map((c) {
          if (c is CupertinoDynamicColor) {
            return CupertinoDynamicColor.resolve(c, context);
          }
          return c;
        }).toList(),
        begin: linear.begin,
        end: linear.end,
        stops: linear.stops,
        tileMode: linear.tileMode,
        transform: linear.transform,
      );
    }

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedGradient == null
            ? resolvedColor ?? Theme.of(context).cardColor
            : null,
        gradient: resolvedGradient,
        borderRadius: radius,
        border: Border.all(
          color:
              resolvedBorderColor ??
              theme.colorScheme.outlineVariant.withValues(
                alpha: isDark ? 0.50 : 0.35,
              ),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color:
                      resolvedShadowColor ??
                      Colors.black.withValues(alpha: 0.055),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}
