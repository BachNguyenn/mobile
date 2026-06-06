import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/presentation/widgets/global_search_delegate.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

class MiniDictionaryOverlay extends ConsumerWidget {
  final Widget child;
  final bool enabled;

  const MiniDictionaryOverlay({
    super.key,
    required this.child,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enabled) return child;

    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => child,
        ),
        OverlayEntry(
          builder: (context) => Positioned(
            right: AppSpacing.sp16,
            bottom: 88,
            child: SafeArea(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: IconButton.filledTonal(
                  tooltip: 'Tra cứu nhanh',
                  onPressed: () {
                    final navContext = globalNavigatorKey.currentContext;
                    if (navContext != null) {
                      showSearch(
                        context: navContext,
                        delegate: GlobalSearchDelegate(ref),
                      );
                    }
                  },
                  icon: const Icon(Icons.manage_search_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: resolvedZenBlue.withValues(alpha: 0.12),
                    foregroundColor: resolvedZenBlue,
                    minimumSize: const Size.square(48),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
