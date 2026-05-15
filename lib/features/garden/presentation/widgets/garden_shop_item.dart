import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';

/// Premium shop item card with gradient background, affordability state,
/// and purchase confirmation animation.
class GardenShopItem extends ConsumerStatefulWidget {
  final String type;
  final String name;
  final int water;
  final int sun;
  final Offset position;

  const GardenShopItem({
    super.key,
    required this.type,
    required this.name,
    required this.water,
    required this.sun,
    required this.position,
  });

  @override
  ConsumerState<GardenShopItem> createState() => _GardenShopItemState();
}

class _GardenShopItemState extends ConsumerState<GardenShopItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  bool _purchased = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _typeGradientStart {
    switch (widget.type) {
      case 'zen_bonsai':
        return AppColors.mossGreen.withValues(alpha: 0.08);
      case 'zen_sakura':
        return AppColors.sakura.withValues(alpha: 0.1);
      case 'zen_stone':
        return AppColors.slateGrey.withValues(alpha: 0.06);
      default:
        return AppColors.creamDark;
    }
  }

  Color get _typeGradientEnd {
    switch (widget.type) {
      case 'zen_bonsai':
        return AppColors.mossLight.withValues(alpha: 0.12);
      case 'zen_sakura':
        return AppColors.petalGlow.withValues(alpha: 0.12);
      case 'zen_stone':
        return AppColors.slateMuted.withValues(alpha: 0.08);
      default:
        return AppColors.cream;
    }
  }

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);
    final canAfford =
        garden.water >= widget.water && garden.sunlight >= widget.sun;

    return GestureDetector(
      onTap: () async {
        if (_purchased) return;

        final success = await ref
            .read(gardenProvider.notifier)
            .buyPlant(
              widget.type,
              widget.position.dx - 40,
              widget.position.dy - 40,
              waterCost: widget.water,
              sunCost: widget.sun,
            );

        if (context.mounted) {
          if (success) {
            setState(() => _purchased = true);
            _pulseController.forward();
            await Future<void>.delayed(const Duration(milliseconds: 500));
            if (context.mounted) Navigator.pop(context);
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không đủ tài nguyên! Hãy học thêm nhé.'),
                backgroundColor: AppColors.terracotta,
              ),
            );
          }
        }
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + _pulseController.value * 0.08;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sp12,
            horizontal: AppSpacing.sp8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_typeGradientStart, _typeGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.slateLight.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Plant image with affordability overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ResizeImage(
                          AssetImage('assets/images/${widget.type}.webp'),
                          width: 128,
                        ),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  // Can't afford overlay
                  if (!canAfford)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  // Purchase check mark
                  if (_purchased)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.8),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                widget.name,
                style: AppTypography.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: canAfford ? AppColors.slateGrey : AppColors.slateMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 12,
                    color: canAfford
                        ? AppColors.waterBlue
                        : AppColors.slateMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.water}',
                    style: AppTypography.labelS.copyWith(
                      color: canAfford
                          ? AppColors.waterBlue
                          : AppColors.slateMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.wb_sunny,
                    size: 12,
                    color: canAfford ? AppColors.sunGold : AppColors.slateMuted,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${widget.sun}',
                    style: AppTypography.labelS.copyWith(
                      color: canAfford
                          ? AppColors.sunGold
                          : AppColors.slateMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
