import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';

import 'package:mobile/features/home/presentation/screens/home_page.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_library_screen.dart';
import 'package:mobile/features/vocabulary/presentation/screens/vocabulary_library_screen.dart';
import 'package:mobile/features/grammar/presentation/screens/grammar_library_screen.dart';
import 'package:mobile/features/learning/presentation/providers/learning_path_provider.dart';
import 'package:mobile/features/learning/presentation/screens/learning_path_screen.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';

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
  LearningCategory _learningCategory = LearningCategory.mixed;

  @override
  void initState() {
    super.initState();
    _pillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pillAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _pillController,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
  }

  @override
  void dispose() {
    _pillController.dispose();
    super.dispose();
  }

  void _openTab(int index, {bool resetLearningCategory = true}) {
    if (index < 0 || index >= 5) return;
    final settings = ref.read(settingsProvider).valueOrNull;
    final targetLearningCategory = resetLearningCategory && index == 1
        ? settings?.defaultLearningCategory ?? LearningCategory.mixed
        : _learningCategory;
    if (index == _selectedIndex &&
        targetLearningCategory == _learningCategory) {
      return;
    }

    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = index;
      _learningCategory = targetLearningCategory;
    });
    if (index == 1 &&
        ref.read(learningCategoryProvider) != targetLearningCategory) {
      ref.read(learningCategoryProvider.notifier).state =
          targetLearningCategory;
    }
    _animatePill(_previousIndex, index);
    _triggerHaptic();
  }

  void _openLearningCategory(LearningCategory category) {
    final previousIndex = _selectedIndex;
    setState(() {
      _previousIndex = _selectedIndex;
      _selectedIndex = 1;
      _learningCategory = category;
    });
    if (ref.read(learningCategoryProvider) != category) {
      ref.read(learningCategoryProvider.notifier).state = category;
    }
    _animatePill(previousIndex, 1);
    _triggerHaptic();
  }

  void _triggerHaptic() {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings?.hapticsEnabled ?? AppSettings.defaults.hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  void _animatePill(int from, int to) {
    _pillAnimation = Tween<double>(begin: from.toDouble(), end: to.toDouble())
        .animate(
          CurvedAnimation(
            parent: _pillController,
            curve: Curves.easeInOutCubicEmphasized,
          ),
        );
    _pillController.forward(from: 0);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          onOpenTab: _openTab,
          onOpenLearningCategory: _openLearningCategory,
        );
      case 1:
        return LearningPathScreen(
          isNavBarMode: true,
          initialCategory: _learningCategory,
        );
      case 2:
        return VocabularyLibraryScreen(
          onOpenLearningCategory: _openLearningCategory,
        );
      case 3:
        return GrammarLibraryScreen(
          onOpenLearningCategory: _openLearningCategory,
        );
      case 4:
        return KanjiLibraryScreen(
          onOpenLearningCategory: _openLearningCategory,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentScreen(),

      // ── Premium Bottom Navigation Bar ──────────────────────
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedIndex,
        pillAnimation: _pillAnimation,
        pillController: _pillController,
        onItemTap: _openTab,
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
    icon: Icons.psychology_outlined,
    activeIcon: Icons.psychology_rounded,
    label: 'Tổng hợp',
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
                      final pillLeft =
                          currentPos * itemWidth +
                          (itemWidth - AppSpacing.navBarItemMinWidth) / 2;

                      return Positioned(
                        left: pillLeft,
                        top:
                            (AppSpacing.bottomNavHeight -
                                AppSpacing.navBarPillHeight) /
                            2,
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
                return Transform.scale(scale: scale, child: child);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? data.activeIcon : data.icon,
                  key: ValueKey('${data.label}_$isSelected'),
                  size: 24,
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateMuted,
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
// End of MainNavigation
