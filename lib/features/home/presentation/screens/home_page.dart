import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/domain/entities/zen_garden.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/widgets/collapsed_title.dart';
import 'package:mobile/features/home/presentation/widgets/daily_progress_card.dart';
import 'package:mobile/features/home/presentation/widgets/hero_header.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/features/home/presentation/widgets/quick_action_chips.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/presentation/widgets/global_search_delegate.dart';
import 'package:mobile/presentation/widgets/learning_card.dart';
import 'package:mobile/presentation/widgets/zen_garden_2d_widget.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerStatefulWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final garden = ref.watch(gardenProvider);
    final progressAsync = ref.watch(homeProgressProvider);
    final authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;

    return progressAsync.when(
      data: (progress) => _buildContent(context, ref, garden, progress, user),
      loading: () =>
          _buildContent(context, ref, garden, HomeProgress.empty, user),
      error: (e, _) =>
          _buildContent(context, ref, garden, HomeProgress.empty, user),
    );
  }

  Widget _staggeredItem({required int index, required Widget child}) {
    final delay = index * 0.12;
    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final progress =
            ((_staggerController.value - delay) / 0.4).clamp(0.0, 1.0);
        final curve = Curves.easeOutCubic.transform(progress);
        return Transform.translate(
          offset: Offset(0, 20 * (1 - curve)),
          child: Opacity(
            opacity: curve,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ZenGarden garden,
    HomeProgress progress,
    User? user,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.cream,
          surfaceTintColor: Colors.transparent,
          title: const CollapsedTitle(),
          actions: [
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: GlobalSearchDelegate(ref),
                );
              },
              icon: const Icon(Icons.search_rounded, size: 22),
              color: AppColors.slateGrey,
              tooltip: 'Tìm kiếm',
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sp12),
              child: ProfileAvatar(user: user),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: AppSpacing.zenHeaderExpandedHeight,
            child: HeroHeader(
              progress: progress,
              streak: progress.streak,
              overdueCount: progress.overdueCount,
              todayReviewed: progress.todayReviewed,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _staggeredItem(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp24,
                AppSpacing.sp20,
                AppSpacing.sp24,
                AppSpacing.sp8,
              ),
              child: DailyProgressCard(progress: progress),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _staggeredItem(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp24,
                AppSpacing.sp16,
                AppSpacing.sp24,
                AppSpacing.sp8,
              ),
              child: ZenGarden2DWidget(
                garden: garden,
                streak: progress.streak,
                onTap: () {
                  Navigator.push(context, AppRoutes.garden());
                },
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _staggeredItem(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.sp16,
                bottom: AppSpacing.sp8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: AppSpacing.paddingH24,
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          size: 18,
                          color: AppColors.sunGold,
                        ),
                        const SizedBox(width: AppSpacing.sp8),
                        Text(
                          'Hành động nhanh',
                          style: AppTypography.headingM,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sp12),
                  QuickActionChips(
                    ref: ref,
                    context: context,
                    onOpenLearningCategory: widget.onOpenLearningCategory,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _staggeredItem(
            index: 3,
            child: const _ZenDivider(),
          ),
        ),
        SliverToBoxAdapter(
          child: _staggeredItem(
            index: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sp24,
                AppSpacing.sp8,
                AppSpacing.sp24,
                AppSpacing.sp12,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 20,
                    color: AppColors.mossGreen,
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Text('Bắt đầu học', style: AppTypography.headingM),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: AppSpacing.paddingH24,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _staggeredItem(
                index: 5,
                child: LearningCard(
                  title: 'Từ vựng',
                  subtitle: 'Mở rộng vốn từ và nhận mặt cụm quen dùng',
                  badge: 'Theo chủ đề',
                  metricLabel: 'Đã học',
                  metricValue:
                      '${progress.vocabulary.learned}/${progress.vocabulary.total}',
                  highlights: const ['Từ mới', 'Ngữ cảnh'],
                  icon: Icons.menu_book_rounded,
                  progress: progress.vocabulary.percentage,
                  heroTag: 'vocabulary_card',
                  accentColor: AppColors.waterBlue,
                  onTap: () {
                    widget.onOpenTab?.call(2);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sp16),
              _staggeredItem(
                index: 6,
                child: LearningCard(
                  title: 'Ngữ pháp',
                  subtitle: 'Luyện mẫu câu và cách dùng từ N5 đến N1',
                  badge: 'Mẫu câu',
                  metricLabel: 'Tiến độ',
                  metricValue:
                      '${(progress.grammar.percentage * 100).round()}% hoàn thành',
                  highlights: const ['Cấu trúc', 'Ví dụ'],
                  icon: Icons.edit_note_rounded,
                  progress: progress.grammar.percentage,
                  heroTag: 'grammar_card',
                  accentColor: AppColors.sunGold,
                  onTap: () {
                    widget.onOpenTab?.call(3);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sp16),
              _staggeredItem(
                index: 7,
                child: LearningCard(
                  title: 'Chữ Hán',
                  subtitle: 'Tập viết, nhớ nghĩa và nối âm đọc Kanji',
                  badge: 'Nét viết',
                  metricLabel: 'Đã nhớ',
                  metricValue:
                      '${progress.kanji.learned}/${progress.kanji.total} ký tự',
                  highlights: const ['On/Kun', 'Viết tay'],
                  icon: Icons.translate_rounded,
                  progress: progress.kanji.percentage,
                  heroTag: 'kanji_card',
                  accentColor: AppColors.mossGreen,
                  onTap: () {
                    widget.onOpenTab?.call(4);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sp48),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ZenDivider extends StatelessWidget {
  const _ZenDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp48,
        vertical: AppSpacing.sp16,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp12),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.slateMuted.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 0.5,
              color: AppColors.slateLight.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
