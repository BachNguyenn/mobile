import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/models/progress_models.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/garden/presentation/providers/garden_mission_provider.dart';
import 'package:mobile/features/home/domain/services/daily_study_coach.dart';
import 'package:mobile/features/home/presentation/providers/daily_study_plan_provider.dart';
import 'package:mobile/features/home/presentation/providers/home_progress_provider.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/features/home/presentation/widgets/quick_action_chips.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

typedef TabSwitchCallback = void Function(int index);
typedef LearningCategoryCallback = void Function(LearningCategory category);

class HomePage extends ConsumerWidget {
  final TabSwitchCallback? onOpenTab;
  final LearningCategoryCallback? onOpenLearningCategory;

  const HomePage({super.key, this.onOpenTab, this.onOpenLearningCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(homeProgressProvider).valueOrNull;
    final dailyPlan = ref.watch(dailyStudyPlanProvider);
    final missions = ref.watch(gardenMissionProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final data = progress ?? HomeProgress.empty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppPageBackground(
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sp20,
                  AppSpacing.sp12,
                  AppSpacing.sp20,
                  116,
                ),
                sliver: SliverList.list(
                  children: [
                    _TopBar(user: user),
                    const SizedBox(height: AppSpacing.sp24),
                    _DailyStudyCard(
                      plan: dailyPlan,
                      progress: data,
                      onTap: (plan) => openDailyStudyPlan(
                        context,
                        ref,
                        plan,
                        onOpenLearningCategory: onOpenLearningCategory,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    _ReviewStrip(
                      overdueCount: data.overdueCount,
                      todayReviewed: data.todayReviewed,
                      streak: data.streak,
                      onTap: () => openWeakAreaReview(context, ref),
                    ),
                    const SizedBox(height: AppSpacing.sp24),
                    const _SectionTitle(
                      title: 'Học nhanh',
                      subtitle:
                          'Chọn đúng phần cần học, không phải đi lòng vòng.',
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    _LearningGrid(
                      onVocabulary: () => onOpenTab?.call(2),
                      onGrammar: () => onOpenTab?.call(3),
                      onKanji: () => onOpenTab?.call(4),
                      onQuiz: () => _openLearning(context),
                      onMission: () =>
                          Navigator.push(context, AppRoutes.garden()),
                      onProfile: () =>
                          Navigator.push(context, AppRoutes.analytics()),
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    _MissionCard(
                      missions: missions,
                      onTap: () => Navigator.push(context, AppRoutes.garden()),
                    ),
                    const SizedBox(height: AppSpacing.sp24),
                    _ZenGardenCard(
                      onTap: () => Navigator.push(context, AppRoutes.garden()),
                    ),
                    const SizedBox(height: AppSpacing.sp24),
                    const _SectionTitle(
                      title: 'Tiến độ',
                      subtitle: 'Ba mảng chính của lộ trình hiện tại.',
                    ),
                    const SizedBox(height: AppSpacing.sp12),
                    _ProgressList(progress: data, onOpenTab: onOpenTab),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLearning(BuildContext context) {
    final callback = onOpenLearningCategory;
    if (callback != null) {
      callback(LearningCategory.mixed);
    } else {
      Navigator.push(context, AppRoutes.learningPath());
    }
  }
}

class _TopBar extends StatelessWidget {
  final User? user;

  const _TopBar({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(color: AppColors.navySoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset('assets/images/app_logo_clean.png'),
        ),
        const SizedBox(width: AppSpacing.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headingS.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '日本語を少しずつ',
                style: AppTypography.label.copyWith(
                  color: AppColors.leafDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Tìm kiếm',
          onPressed: () => Navigator.push(context, AppRoutes.dictionary()),
          icon: const Icon(Icons.search_rounded),
          color: AppColors.zenBlue,
        ),
        ProfileAvatar(user: user),
      ],
    );
  }

  String _displayName(User? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'bạn';
  }
}

class _DailyStudyCard extends StatelessWidget {
  final AsyncValue<DailyStudyPlan> plan;
  final HomeProgress progress;
  final ValueChanged<DailyStudyPlan> onTap;

  const _DailyStudyCard({
    required this.plan,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress.overallPercentage * 100).round();
    final currentPlan = plan.valueOrNull;
    final title = currentPlan?.title ?? 'Đang chọn phiên học';
    final subtitle =
        currentPlan?.subtitle ?? 'Đang chọn phiên học phù hợp cho bạn.';
    final reason = currentPlan?.reason ?? 'Dựa trên tiến độ hiện tại';
    final icon = switch (currentPlan?.actionType) {
      DailyStudyActionType.review => Icons.replay_rounded,
      DailyStudyActionType.lesson => Icons.route_rounded,
      DailyStudyActionType.placement => Icons.fact_check_rounded,
      DailyStudyActionType.sentencePractice => Icons.subject_rounded,
      null => Icons.psychology_alt_rounded,
    };

    return AppCard(
      onTap: currentPlan == null ? null : () => onTap(currentPlan),
      color: AppColors.zenBlue,
      borderColor: AppColors.zenBlue,
      shadowColor: AppColors.zenBlue.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(AppSpacing.sp20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sp12,
                  vertical: AppSpacing.sp8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AppColors.leafLight,
                    ),
                    const SizedBox(width: AppSpacing.sp4),
                    Text(
                      'Hôm nay học gì?',
                      style: AppTypography.label.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (currentPlan != null)
                _DailyStudyPill(
                  icon: Icons.flag_rounded,
                  label: 'N${currentPlan.level}',
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headingM.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyM.copyWith(
                        color: AppColors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp16),
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: plan.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.white,
                          ),
                        )
                      : Icon(icon, color: AppColors.white, size: 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp20),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: [
              _DailyStudyPill(
                icon: Icons.tips_and_updates_rounded,
                label: reason,
              ),
              if (currentPlan != null && currentPlan.itemCount > 0)
                _DailyStudyPill(
                  icon: Icons.format_list_numbered_rounded,
                  label: '${currentPlan.itemCount} mục',
                ),
              _DailyStudyPill(
                icon: Icons.insights_rounded,
                label: '$percent% tiến độ',
              ),
              _DailyStudyPill(
                icon: Icons.local_fire_department_rounded,
                label: '${progress.streak} ngày',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp20),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
            child: LinearProgressIndicator(
              value: progress.overallPercentage.clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              backgroundColor: AppColors.white.withValues(alpha: 0.14),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.leafLight,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sp16),
          Row(
            children: [
              Text(
                currentPlan == null ? 'Đang chuẩn bị' : 'Bắt đầu ngay',
                style: AppTypography.label.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: AppSpacing.sp8),
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.white.withValues(
                  alpha: currentPlan == null ? 0.5 : 1,
                ),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyStudyPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DailyStudyPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp12,
        vertical: AppSpacing.sp8,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.white.withValues(alpha: 0.82)),
          const SizedBox(width: AppSpacing.sp4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelS.copyWith(
              color: AppColors.white.withValues(alpha: 0.86),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStrip extends StatelessWidget {
  final int overdueCount;
  final int todayReviewed;
  final int streak;
  final VoidCallback onTap;

  const _ReviewStrip({
    required this.overdueCount,
    required this.todayReviewed,
    required this.streak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sp16),
      borderColor: AppColors.leafGreen.withValues(alpha: 0.14),
      shadowColor: AppColors.leafGreen.withValues(alpha: 0.05),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.leafGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: const Icon(
              Icons.refresh_rounded,
              color: AppColors.leafGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overdueCount > 0
                      ? '$overdueCount thẻ đang chờ ôn'
                      : 'Không có thẻ đến hạn',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMBold.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Đã ôn $todayReviewed hôm nay · streak $streak',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, color: AppColors.leafGreen),
        ],
      ),
    );
  }
}

class _LearningGrid extends StatelessWidget {
  final VoidCallback? onVocabulary;
  final VoidCallback? onGrammar;
  final VoidCallback? onKanji;
  final VoidCallback onQuiz;
  final VoidCallback onMission;
  final VoidCallback onProfile;

  const _LearningGrid({
    this.onVocabulary,
    this.onGrammar,
    this.onKanji,
    required this.onQuiz,
    required this.onMission,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem(
        title: 'Từ vựng',
        icon: Icons.menu_book_rounded,
        color: AppColors.zenBlue,
        onTap: onVocabulary,
      ),
      _MenuItem(
        title: 'Ngữ pháp',
        icon: Icons.edit_note_rounded,
        color: AppColors.leafGreen,
        onTap: onGrammar,
      ),
      _MenuItem(
        title: 'Chữ Hán',
        icon: Icons.translate_rounded,
        color: AppColors.waterBlue,
        onTap: onKanji,
      ),
      _MenuItem(
        title: 'Quiz',
        icon: Icons.quiz_rounded,
        color: AppColors.zenBlue,
        onTap: onQuiz,
      ),
      _MenuItem(
        title: 'Vườn',
        icon: Icons.flag_rounded,
        color: AppColors.leafGreen,
        onTap: onMission,
      ),
      _MenuItem(
        title: 'Hồ sơ',
        icon: Icons.insights_rounded,
        color: AppColors.slateGrey,
        onTap: onProfile,
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.sp8,
        mainAxisSpacing: AppSpacing.sp8,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) => _MenuTile(item: items[index]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusM),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sp12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.slateLight.withValues(alpha: 0.32),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const SizedBox(height: AppSpacing.sp8),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.label.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final AsyncValue<GardenMissionSummary> missions;
  final VoidCallback onTap;

  const _MissionCard({required this.missions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return missions.when(
      data: (summary) {
        return AppCard(
          onTap: onTap,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp16,
            AppSpacing.sp12,
            AppSpacing.sp16,
            AppSpacing.sp12,
          ),
          borderColor: AppColors.leafGreen.withValues(alpha: 0.14),
          shadowColor: AppColors.leafGreen.withValues(alpha: 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nhiệm vụ hôm nay',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${summary.completedCount}/${summary.missions.length}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.leafGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp12),
              ...summary.missions.map((mission) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sp8),
                  child: _MissionRow(mission: mission),
                );
              }),
            ],
          ),
        );
      },
      loading: () => const AppCard(child: SizedBox(height: 84)),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _MissionRow extends StatelessWidget {
  final GardenMission mission;

  const _MissionRow({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(mission.icon, color: mission.color, size: 21),
        const SizedBox(width: AppSpacing.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      mission.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMBold.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp8),
                  Text(
                    '${mission.current}/${mission.target}',
                    style: AppTypography.label.copyWith(
                      color: mission.color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp4),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                child: LinearProgressIndicator(
                  value: mission.progress,
                  minHeight: 5,
                  backgroundColor: AppColors.creamDark,
                  valueColor: AlwaysStoppedAnimation<Color>(mission.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ZenGardenCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ZenGardenCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderColor: AppColors.leafGreen.withValues(alpha: 0.14),
      shadowColor: AppColors.leafGreen.withValues(alpha: 0.06),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusL),
        child: SizedBox(
          height: 148,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/zen_bonsai.webp',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.zenBlue.withValues(alpha: 0.92),
                      AppColors.zenBlue.withValues(alpha: 0.64),
                      AppColors.zenBlue.withValues(alpha: 0.10),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sp16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Khu vườn Zen',
                          style: AppTypography.headingS.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sp4),
                        SizedBox(
                          width: 190,
                          child: Text(
                            'Hoàn thành nhiệm vụ để nuôi khu vườn học tập.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyS.copyWith(
                              color: AppColors.white.withValues(alpha: 0.78),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sp12,
                        vertical: AppSpacing.sp4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXL,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Mở vườn',
                            style: AppTypography.label.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sp4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressList extends StatelessWidget {
  final HomeProgress progress;
  final TabSwitchCallback? onOpenTab;

  const _ProgressList({required this.progress, this.onOpenTab});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sp16),
      child: Column(
        children: [
          _ProgressRow(
            title: 'Từ vựng',
            icon: Icons.menu_book_rounded,
            color: AppColors.zenBlue,
            progress: progress.vocabulary,
            onTap: () => onOpenTab?.call(2),
          ),
          const Divider(height: AppSpacing.sp24),
          _ProgressRow(
            title: 'Ngữ pháp',
            icon: Icons.edit_note_rounded,
            color: AppColors.leafGreen,
            progress: progress.grammar,
            onTap: () => onOpenTab?.call(3),
          ),
          const Divider(height: AppSpacing.sp24),
          _ProgressRow(
            title: 'Chữ Hán',
            icon: Icons.translate_rounded,
            color: AppColors.waterBlue,
            progress: progress.kanji,
            onTap: () => onOpenTab?.call(4),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final ModuleProgress progress;
  final VoidCallback onTap;

  const _ProgressRow({
    required this.title,
    required this.icon,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress.percentage * 100).round();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusS),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMBold.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  child: LinearProgressIndicator(
                    value: progress.percentage.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: AppColors.creamDark,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sp12),
          Text(
            '$percent%',
            style: AppTypography.label.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.headingS.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(subtitle, style: AppTypography.caption),
      ],
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });
}
