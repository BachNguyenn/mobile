import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class StartupLoadingScreen extends StatefulWidget {
  final String message;

  const StartupLoadingScreen({super.key, required this.message});

  @override
  State<StartupLoadingScreen> createState() => _StartupLoadingScreenState();
}

class _StartupLoadingScreenState extends State<StartupLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _breath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _breath = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = AppColors.resolve(AppColors.zenBlue, context);
    final leaf = AppColors.resolve(AppColors.leafGreen, context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: AppPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sp24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedBuilder(
                      animation: _breath,
                      builder: (context, child) {
                        final scale = 0.98 + (_breath.value * 0.035);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _StartupLogo(primary: primary),
                    ),
                    const SizedBox(height: AppSpacing.sp24),
                    Text(
                      'Zen Japanese',
                      textAlign: TextAlign.center,
                      style: AppTypography.displayLarge.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Text(
                      '日本語を学ぼう',
                      textAlign: TextAlign.center,
                      style: AppTypography.japaneseQuote.copyWith(
                        color: leaf,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp32),
                    _StartupProgress(
                      color: primary,
                      trackColor: colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: AppSpacing.sp16),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyM.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StartupLogo extends StatelessWidget {
  final Color primary;

  const _StartupLogo({required this.primary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        width: 108,
        height: 108,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.50),
          ),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Transform.scale(
          scale: 1.28,
          child: Image.asset(
            'assets/images/splash_logo_compact.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}

class _StartupProgress extends StatelessWidget {
  final Color color;
  final Color trackColor;

  const _StartupProgress({required this.color, required this.trackColor});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
      child: LinearProgressIndicator(
        minHeight: 6,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }
}
