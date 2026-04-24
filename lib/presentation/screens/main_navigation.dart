import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

import '../widgets/global_search_delegate.dart';
import 'home_page.dart';
import 'kanji_library_screen.dart';

/// Main Navigation — Bottom Navigation Bar với 4 Tab
///
/// Tabs:
/// 0: Trang chủ (HomePage)
/// 1: Từ vựng (placeholder)
/// 2: Ngữ pháp (placeholder)
/// 3: Chữ Hán (KanjiLibraryScreen)
///
/// Features:
/// - IndexedStack giữ state các tab khi chuyển đổi
/// - Glassmorphism Search Button trên AppBar
/// - Japandi-styled Bottom Navigation Bar
/// - Fade transition khi chuyển tab
class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  void _switchToTab(int index) {
    if (index >= 0 && index < 4) {
      setState(() => _selectedIndex = index);
    }
  }

  // Build screens — HomePage receives the tab switch callback
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

  void _openGlobalSearch() {
    showSearch(
      context: context,
      delegate: GlobalSearchDelegate(ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body: IndexedStack giữ state các tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      // ── Glassmorphism Search FAB ──────────────────────────
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.small(
              onPressed: _openGlobalSearch,
              elevation: 2,
              backgroundColor: AppColors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.mossGreen,
                size: 22,
              ),
            )
          : null,

      // ── Bottom Navigation Bar ─────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_filled,
                  label: 'Trang chủ',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book_rounded,
                  label: 'Từ vựng',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.edit_note_outlined,
                  activeIcon: Icons.edit_note_rounded,
                  label: 'Ngữ pháp',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.translate_outlined,
                  activeIcon: Icons.translate_rounded,
                  label: 'Chữ Hán',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                width: isSelected ? 24 : 0,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp4),
                decoration: BoxDecoration(
                  color: AppColors.mossGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  size: 24,
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sp4),

              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
