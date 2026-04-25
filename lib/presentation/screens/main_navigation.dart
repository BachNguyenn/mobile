import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

import 'home_page.dart';
import 'kanji_library_screen.dart';

/// Main Navigation — Bottom Navigation Bar với 4 Tab (Premium Redesign)
///
/// Tabs:
/// 0: Trang chủ (HomePage)
/// 1: Từ vựng (placeholder)
/// 2: Ngữ pháp (placeholder)
/// 3: Chữ Hán (KanjiLibraryScreen)
///
/// Features:
/// - Animated pill indicator trượt mượt theo tab active
/// - Icon scale animation khi active
/// - InkWell + haptic feedback cho mỗi nav item
/// - Profile avatar + search icon trên AppBar
/// - IndexedStack giữ state các tab khi chuyển đổi
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _pillController;
  late Animation<double> _pillAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pillAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _pillController, curve: Curves.easeInOutCubicEmphasized),
    );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _switchToTab(int index) {
    if (index < 0 || index >= 4 || index == _selectedIndex) return;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
    });
    _animatePill(_previousIndex, index);
    HapticFeedback.selectionClick();
  }

  void _animatePill(int from, int to) {
    _pillAnimation = Tween<double>(
      begin: from.toDouble(),
      end: to.toDouble(),
    ).animate(
      CurvedAnimation(parent: _pillController, curve: Curves.easeInOutCubicEmphasized),
    );
    _pillController.forward(from: 0);
  }

  List<Widget> get _screens => [
        HomePage(onSwitchTab: _switchToTab),
        const _PlaceholderTab(
          title: 'Từ vựng',
          subtitle: 'Sắp ra mắt',
          icon: Icons.menu_book_rounded,
        ),
        const _PlaceholderTab(
          title: 'Ngữ pháp',
          subtitle: 'Sắp ra mắt',
          icon: Icons.edit_note_rounded,
        ),
        const KanjiLibraryScreen(),
      ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // ── Premium Bottom Navigation Bar ──────────────────────
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedIndex,
        pillAnimation: _pillAnimation,
        pillController: _pillController,
        onItemTap: _switchToTab,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Premium Bottom Navigation Bar
// ═══════════════════════════════════════════════════════════════

/// Bottom Nav data
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItemData(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Trang chủ',
  ),
  _NavItemData(
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book_rounded,
    label: 'Từ vựng',
  ),
  _NavItemData(
    icon: Icons.edit_note_outlined,
    activeIcon: Icons.edit_note_rounded,
    label: 'Ngữ pháp',
  ),
  _NavItemData(
    icon: Icons.translate_outlined,
    activeIcon: Icons.translate_rounded,
    label: 'Chữ Hán',
  ),
];

class _PremiumBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Animation<double> pillAnimation;
  final AnimationController pillController;
  final ValueChanged<int> onItemTap;

  const _PremiumBottomNav({
    required this.selectedIndex,
    required this.pillAnimation,
    required this.pillController,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppSpacing.bottomNavHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _navItems.length;

              return Stack(
                children: [
                  // ── Sliding Pill Indicator ──────────────────
                  AnimatedBuilder(
                    animation: pillController,
                    builder: (context, _) {
                      final currentPos = pillAnimation.value;
                      final pillLeft = currentPos * itemWidth +
                          (itemWidth - AppSpacing.navBarItemMinWidth) / 2;

                      return Positioned(
                        left: pillLeft,
                        top: (AppSpacing.bottomNavHeight - AppSpacing.navBarPillHeight) / 2,
                        child: Container(
                          width: AppSpacing.navBarItemMinWidth,
                          height: AppSpacing.navBarPillHeight,
                          decoration: BoxDecoration(
                            color: AppColors.navPillBg,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.navBarPillRadius,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── Nav Items Row ──────────────────────────
                  Row(
                    children: List.generate(_navItems.length, (index) {
                      return Expanded(
                        child: _NavItem(
                          data: _navItems[index],
                          isSelected: selectedIndex == index,
                          onTap: () => onItemTap(index),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Single nav item with animated icon scale + color transition
class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.mossGreen.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: AppSpacing.bottomNavHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with scale animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? data.activeIcon : data.icon,
                  key: ValueKey('${data.label}_$isSelected'),
                  size: 24,
                  color: isSelected ? AppColors.mossGreen : AppColors.slateMuted,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sp4),

            // Label with animated color
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelS.copyWith(
                color: isSelected ? AppColors.mossGreen : AppColors.slateMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(data.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Placeholder Tabs
// ═══════════════════════════════════════════════════════════════

/// Placeholder tab cho Từ vựng / Ngữ pháp — giữ nguyên theo yêu cầu
class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PlaceholderTab({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mossGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.mossGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.sp24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sp8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.slateMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
