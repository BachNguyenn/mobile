import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/models/progress_models.dart';
import '../providers/grammar_library_provider.dart';
import '../../../../shared/widgets/progress_card.dart';
import '../../../../shared/widgets/action_button.dart';
import '../../../../presentation/providers/learning_path_provider.dart';
import '../../../../presentation/screens/learning_path_screen.dart';

class GrammarLibraryScreen extends ConsumerWidget {
  const GrammarLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResults = ref.watch(grammarSearchResultsProvider);
    final progressAsync = ref.watch(grammarProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.sunGold,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Hero(
                tag: 'grammar_card',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Thư viện Ngữ pháp',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.sunGold, AppColors.sunGold.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp16, AppSpacing.sp16, AppSpacing.sp8),
              child: progressAsync.when(
                data: (progress) => LibraryProgressCard(
                  progress: progress,
                  dueCount: 0,
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
                loading: () => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
                error: (e, _) => const LibraryProgressCard(
                  progress: ModuleProgress.empty,
                  dueCount: 0,
                  title: 'Ngữ pháp',
                  icon: Icons.edit_note_rounded,
                  color: AppColors.sunGold,
                ),
              ),
            ),
          ),

          // ── Action Buttons (Ôn tập + Bài mới) ──────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sp16,
                vertical: AppSpacing.sp8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.auto_stories_rounded,
                      label: 'Ôn tập',
                      sublabel: 'Tạm chưa khả dụng',
                      color: AppColors.terracotta,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp12),
                  Expanded(
                    child: KanjiActionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Bài mới',
                      sublabel: 'Lộ trình học',
                      color: AppColors.sunGold,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LearningPathScreen(
                              isNavBarMode: true,
                              initialCategory: LearningCategory.grammar,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sp8),
              child: _LevelSelector(),
            ),
          ),

          // ── Search Bar ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp8, AppSpacing.sp16, AppSpacing.sp8),
              child: TextField(
                onChanged: (value) =>
                    ref.read(grammarSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm điểm ngữ pháp...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.sunGold),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: BorderSide(
                      color: AppColors.slateLight.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    borderSide: const BorderSide(
                      color: AppColors.sunGold,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Section Title ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sp16, AppSpacing.sp8, AppSpacing.sp16, AppSpacing.sp4),
              child: Text(
                'Tất cả ngữ pháp',
                style: AppTypography.bodyMBold.copyWith(color: AppColors.slateGrey),
              ),
            ),
          ),

          searchResults.when(
            data: (grammarList) {
              if (grammarList.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 48, color: AppColors.slateLight),
                        const SizedBox(height: AppSpacing.sp12),
                        Text('Không tìm thấy ngữ pháp nào.', 
                          style: AppTypography.bodyM.copyWith(color: AppColors.slateMuted)),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final grammar = grammarList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sp12),
                        color: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusM),
                          side: BorderSide(color: AppColors.slateLight.withValues(alpha: 0.2)),
                        ),
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(side: BorderSide.none),
                          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                          title: Text(grammar.title, style: AppTypography.headingS.copyWith(color: AppColors.ink)),
                          subtitle: Text(grammar.shortExplanation, style: AppTypography.bodyM.copyWith(color: AppColors.slateGrey)),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.sunGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                            ),
                            child: Text('N${grammar.jlptLevel}', 
                              style: const TextStyle(color: AppColors.sunGold, fontWeight: FontWeight.bold)),
                          ),
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppSpacing.sp16),
                              decoration: BoxDecoration(
                                color: AppColors.cream.withValues(alpha: 0.5),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusM)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSection('Cấu trúc', grammar.formation),
                                  const SizedBox(height: AppSpacing.sp12),
                                  _buildSection('Giải thích', grammar.longExplanation),
                                  const SizedBox(height: AppSpacing.sp12),
                                  Text('Ví dụ:', style: AppTypography.bodyMBold.copyWith(color: AppColors.sunGold)),
                                  ...grammar.examples.map((ex) => Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('• ${ex.jp}', style: AppTypography.bodyM.copyWith(fontWeight: FontWeight.w500)),
                                        if (ex.en.isNotEmpty)
                                          Text('  ${ex.en}', style: AppTypography.bodyS.copyWith(color: AppColors.slateMuted)),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: grammarList.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.sunGold))),
            error: (e, _) => SliverFillRemaining(child: Center(child: Text('Lỗi: $e'))),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sp48)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title:', style: AppTypography.bodyMBold.copyWith(color: AppColors.sunGold)),
        const SizedBox(height: 2),
        Text(content, style: AppTypography.bodyM),
      ],
    );
  }
}

class _LevelSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(grammarLevelFilterProvider);
    final levels = [null, 5, 4, 3, 2, 1];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isSelected = currentFilter == level;
          final label = level == null ? 'Tất cả' : 'N$level';

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sp8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: AppColors.sunGold.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.sunGold : AppColors.slateGrey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                ref.read(grammarLevelFilterProvider.notifier).state = selected ? level : null;
              },
            ),
          );
        },
      ),
    );
  }
}
