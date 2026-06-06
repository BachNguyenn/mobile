import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/grammar/presentation/screens/grammar_library_screen.dart';
import 'package:mobile/features/home/presentation/screens/home_page.dart';
import 'package:mobile/features/kanji/presentation/screens/kanji_library_screen.dart';
import 'package:mobile/features/learning/application/providers/learning_path_provider.dart';
import 'package:mobile/features/learning/presentation/screens/learning_path_screen.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/vocabulary/presentation/screens/vocabulary_library_screen.dart';

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
  final Set<int> _initializedIndices = {0};

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
    if (index < 0 || index >= _navItems.length) return;
    final settings = ref.read(settingsProvider).value;
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
      _initializedIndices.add(index);
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
      _initializedIndices.add(1);
    });
    if (ref.read(learningCategoryProvider) != category) {
      ref.read(learningCategoryProvider.notifier).state = category;
    }
    _animatePill(previousIndex, 1);
    _triggerHaptic();
  }

  void _triggerHaptic() {
    final settings = ref.read(settingsProvider).value;
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
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildTab(
          0,
          HomePage(
            onOpenTab: _openTab,
            onOpenLearningCategory: _openLearningCategory,
          ),
        ),
        _buildTab(
          1,
          LearningPathScreen(
            isNavBarMode: true,
            initialCategory: _learningCategory,
          ),
        ),
        _buildTab(2, const VocabularyLibraryScreen()),
        _buildTab(3, const GrammarLibraryScreen()),
        _buildTab(4, const KanjiLibraryScreen()),
      ],
    );
  }

  Widget _buildTab(int index, Widget child) {
    if (!_initializedIndices.contains(index)) return const SizedBox.shrink();

    return TickerMode(
      enabled: _selectedIndex == index,
      child: RepaintBoundary(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _buildCurrentScreen(),
      bottomNavigationBar: _PremiumBottomNav(
        selectedIndex: _selectedIndex,
        pillAnimation: _pillAnimation,
        pillController: _pillController,
        onItemTap: _openTab,
      ),
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.sp16,
        0,
        AppSpacing.sp16,
        AppSpacing.sp20,
      ),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: isDark ? 0.82 : 0.90),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF353F6C).withValues(alpha: 0.25)
                    : resolvedZenBlue.withValues(alpha: 0.06),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _navItems.length;
                const pillWidth = 20.0;

                return Stack(
                  children: [
                    AnimatedBuilder(
                      animation: pillController,
                      builder: (context, _) {
                        final currentPos = pillAnimation.value;
                        final pillLeft =
                            currentPos * itemWidth + (itemWidth - pillWidth) / 2;

                        return Positioned(
                          left: pillLeft,
                          bottom: 5,
                          child: Container(
                            width: pillWidth,
                            height: 3,
                            decoration: BoxDecoration(
                              color: resolvedZenBlue,
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        );
                      },
                    ),
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
      ),
    );
  }
}

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
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);
    final resolvedSlateMuted = AppColors.resolve(AppColors.slateMuted, context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: resolvedZenBlue.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: isSelected ? 1.10 : 1.0),
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
                    size: 22,
                    color: isSelected ? resolvedZenBlue : resolvedSlateMuted,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTypography.labelS.copyWith(
                  color: isSelected ? resolvedZenBlue : resolvedSlateMuted,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10,
                ),
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
