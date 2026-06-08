import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/learning/domain/entities/learning_goal.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'package:mobile/features/settings/domain/entities/app_theme_mode.dart';
import 'package:mobile/features/sync/application/providers/progress_sync_provider.dart';
import 'package:mobile/features/sync/domain/entities/progress_sync_summary.dart';
import 'package:mobile/shared/widgets/app_empty_state.dart';
import 'package:mobile/shared/widgets/app_loading_indicator.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';
import 'package:mobile/shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: AppTypography.headingM.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) {
          return AppPageBackground(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.sp16),
              children: [
                _ProfileSummaryCard(
                  name: _displayName(user),
                  email: user?.email ?? '',
                  photoUrl: user?.photoUrl,
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Giao diện',
                  children: [
                    _ThemeModeTile(
                      selected: settings.themeMode,
                      onChanged: (mode) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateThemeMode(mode);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Hiển thị',
                  children: [
                    _FontScaleTile(
                      selected: settings.fontScale,
                      onChanged: (scale) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateFontScale(scale);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Ngôn ngữ',
                  children: [
                    _LanguageTile(
                      selected: settings.appLanguage,
                      onChanged: (language) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateAppLanguage(language);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Học tập',
                  children: [
                    _CategoryPickerTile(
                      selected: settings.defaultLearningCategory,
                      onChanged: (category) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateDefaultLearningCategory(category);
                      },
                    ),
                    const Divider(height: 1),
                    _LearningGoalTile(
                      selected: settings.learningGoal,
                      onChanged: (goal) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateLearningGoal(goal);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Nhắc học',
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Nhắc học hằng ngày',
                        style: AppTypography.bodyMBold,
                      ),
                      subtitle: Text(
                        settings.dailyReminderEnabled
                            ? 'Đang bật lúc ${_formatTime(settings.reminderHour, settings.reminderMinute)}'
                            : 'Đang tắt',
                        style: AppTypography.caption,
                      ),
                      value: settings.dailyReminderEnabled,
                      activeThumbColor: AppColors.resolve(
                        AppColors.mossGreen,
                        context,
                      ),
                      onChanged: (enabled) async {
                        await ref
                            .read(settingsProvider.notifier)
                            .updateDailyReminderEnabled(enabled);
                        final notificationService = ref.read(
                          notificationServiceProvider,
                        );
                        if (enabled) {
                          await notificationService.scheduleDailyReminder(
                            hour: settings.reminderHour,
                            minute: settings.reminderMinute,
                          );
                        } else {
                          await notificationService.cancelDailyReminder();
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      enabled: settings.dailyReminderEnabled,
                      leading: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.resolve(AppColors.mossGreen, context),
                      ),
                      title: const Text(
                        'Giờ nhắc học',
                        style: AppTypography.bodyMBold,
                      ),
                      subtitle: Text(
                        _formatTime(
                          settings.reminderHour,
                          settings.reminderMinute,
                        ),
                        style: AppTypography.caption,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: settings.dailyReminderEnabled
                          ? () => _pickReminderTime(context, ref, settings)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Trải nghiệm',
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Rung nhẹ khi thao tác',
                        style: AppTypography.bodyMBold,
                      ),
                      subtitle: const Text(
                        'Áp dụng cho thanh điều hướng',
                        style: AppTypography.caption,
                      ),
                      value: settings.hapticsEnabled,
                      activeThumbColor: AppColors.resolve(
                        AppColors.mossGreen,
                        context,
                      ),
                      onChanged: (enabled) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateHapticsEnabled(enabled);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Tài khoản',
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                      ),
                      title: Text(
                        'Đăng xuất',
                        style: AppTypography.bodyMBold.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      onTap: () => _signOut(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp16),
                _SettingsSection(
                  title: 'Đồng bộ',
                  children: [_ProgressSyncTile(user: user)],
                ),
              ],
            ),
          );
        },
        loading: () => const AppPageBackground(
          child: AppLoadingIndicator(color: AppColors.mossGreen),
        ),
        error: (error, _) => AppPageBackground(
          child: AppEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Không tải được cài đặt',
            message: 'Lỗi: $error',
          ),
        ),
      ),
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
    );
    if (picked == null) return;

    await ref
        .read(settingsProvider.notifier)
        .updateReminderTime(hour: picked.hour, minute: picked.minute);
    if (settings.dailyReminderEnabled) {
      await ref
          .read(notificationServiceProvider)
          .scheduleDailyReminder(hour: picked.hour, minute: picked.minute);
    }
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final authRepository = ref.read(authRepositoryProvider);
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    await authRepository.signOut();
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _displayName(AuthUser? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Zen Learner';
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sp4,
            bottom: AppSpacing.sp8,
          ),
          child: Text(
            title,
            style: AppTypography.headingS.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: AppSpacing.sp8,
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileSummaryCard({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedZenBlue = AppColors.resolve(AppColors.zenBlue, context);
    return AppCard(
      color: resolvedZenBlue,
      borderColor: resolvedZenBlue,
      shadowColor: resolvedZenBlue.withValues(alpha: 0.14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.white.withValues(alpha: 0.14),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '禅',
                    style: AppTypography.headingS.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sp16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email.isEmpty ? 'Tài khoản khách' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final AppThemeMode selected;
  final ValueChanged<AppThemeMode> onChanged;

  const _ThemeModeTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SegmentedSetting<AppThemeMode>(
      title: 'Chế độ giao diện',
      subtitle: _themeLabel(selected),
      icon: Icons.contrast_rounded,
      selected: selected,
      values: AppThemeMode.values,
      labelFor: _themeLabel,
      onChanged: onChanged,
    );
  }

  String _themeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'Hệ thống';
      case AppThemeMode.light:
        return 'Sáng';
      case AppThemeMode.dark:
        return 'Tối';
    }
  }
}

class _FontScaleTile extends StatelessWidget {
  final double selected;
  final ValueChanged<double> onChanged;

  const _FontScaleTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SegmentedSetting<double>(
      title: 'Cỡ chữ',
      subtitle: _labelFor(selected),
      icon: Icons.format_size_rounded,
      selected: selected,
      values: const [0.8, 0.85, 0.9, 1.0, 1.15],
      labelFor: _labelFor,
      onChanged: onChanged,
    );
  }

  String _labelFor(double scale) {
    if (scale <= 0.8) return 'Rất nhỏ';
    if (scale <= 0.85) return 'Khá nhỏ';
    if (scale <= 0.9) return 'Nhỏ';
    if (scale > 1.0) return 'Lớn';
    return 'Mặc định';
  }
}

class _LanguageTile extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LanguageTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SegmentedSetting<String>(
      title: 'Ngôn ngữ',
      subtitle: 'Tiếng Việt',
      icon: Icons.language_rounded,
      selected: selected,
      values: const ['vi'],
      labelFor: (_) => 'Tiếng Việt',
      onChanged: onChanged,
    );
  }
}

class _SegmentedSetting<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final T selected;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  const _SegmentedSetting({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedMossGreen = AppColors.resolve(AppColors.mossGreen, context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: resolvedMossGreen),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyMBold),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: values.map((value) {
              final isSelected = value == selected;
              return ChoiceChip(
                label: Text(labelFor(value)),
                selected: isSelected,
                selectedColor: resolvedMossGreen.withValues(alpha: 0.18),
                backgroundColor: Theme.of(context).cardColor,
                showCheckmark: false,
                labelStyle: AppTypography.label.copyWith(
                  color: isSelected
                      ? resolvedMossGreen
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  side: BorderSide(
                    color: isSelected
                        ? resolvedMossGreen
                        : theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.55,
                          ),
                  ),
                ),
                onSelected: (_) => onChanged(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerTile extends StatelessWidget {
  final LearningCategory selected;
  final ValueChanged<LearningCategory> onChanged;

  const _CategoryPickerTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.auto_stories_rounded,
        color: AppColors.resolve(AppColors.mossGreen, context),
      ),
      title: const Text('Lộ trình mặc định', style: AppTypography.bodyMBold),
      subtitle: Text(_labelFor(selected), style: AppTypography.caption),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showCategoryPicker(context),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sp16),
          child: AppCard(
            padding: AppSpacing.cardPadding,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: LearningCategory.values.map((category) {
                final isSelected = category == selected;
                return ListTile(
                  leading: Icon(
                    _iconFor(category),
                    color: isSelected
                        ? AppColors.resolve(AppColors.mossGreen, context)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  title: Text(
                    _labelFor(category),
                    style: AppTypography.bodyMBold,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.resolve(
                            AppColors.mossGreen,
                            context,
                          ),
                        )
                      : null,
                  onTap: () {
                    onChanged(category);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _labelFor(LearningCategory category) {
    switch (category) {
      case LearningCategory.mixed:
        return 'Tổng hợp';
      case LearningCategory.vocabulary:
        return 'Từ vựng';
      case LearningCategory.grammar:
        return 'Ngữ pháp';
      case LearningCategory.kanji:
        return 'Chữ Hán';
    }
  }

  IconData _iconFor(LearningCategory category) {
    switch (category) {
      case LearningCategory.mixed:
        return Icons.psychology_rounded;
      case LearningCategory.vocabulary:
        return Icons.menu_book_rounded;
      case LearningCategory.grammar:
        return Icons.edit_note_rounded;
      case LearningCategory.kanji:
        return Icons.translate_rounded;
    }
  }
}

class _LearningGoalTile extends StatelessWidget {
  final LearningGoal selected;
  final ValueChanged<LearningGoal> onChanged;

  const _LearningGoalTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.flag_rounded,
        color: AppColors.resolve(AppColors.mossGreen, context),
      ),
      title: const Text('Mục tiêu học', style: AppTypography.bodyMBold),
      subtitle: Text(selected.label, style: AppTypography.caption),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showGoalPicker(context),
    );
  }

  void _showGoalPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sp16),
          child: AppCard(
            padding: AppSpacing.cardPadding,
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: LearningGoal.values.map((goal) {
                final isSelected = goal == selected;
                return ListTile(
                  title: Text(goal.label, style: AppTypography.bodyMBold),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: AppColors.resolve(
                            AppColors.mossGreen,
                            context,
                          ),
                        )
                      : null,
                  onTap: () {
                    onChanged(goal);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressSyncTile extends ConsumerWidget {
  final AuthUser? user;

  const _ProgressSyncTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(progressSyncControllerProvider);
    final isBusy = syncState.isLoading;
    final canSync = user != null;
    final resolvedMossGreen = AppColors.resolve(AppColors.mossGreen, context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_sync_rounded, color: resolvedMossGreen),
              const SizedBox(width: AppSpacing.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sao lưu tiến độ',
                      style: AppTypography.bodyMBold,
                    ),
                    Text(_statusLabel(syncState), style: AppTypography.caption),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  tooltip: 'Làm mới',
                  onPressed: canSync
                      ? () => ref
                            .read(progressSyncControllerProvider.notifier)
                            .refresh()
                      : null,
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp12),
          Wrap(
            spacing: AppSpacing.sp8,
            runSpacing: AppSpacing.sp8,
            children: [
              FilledButton.icon(
                onPressed: canSync && !isBusy
                    ? () => _backup(context, ref)
                    : null,
                icon: const Icon(Icons.cloud_upload_rounded),
                label: const Text('Sao lưu'),
              ),
              OutlinedButton.icon(
                onPressed: canSync && !isBusy
                    ? () => _confirmRestore(context, ref)
                    : null,
                icon: const Icon(Icons.cloud_download_rounded),
                label: const Text('Khôi phục'),
              ),
            ],
          ),
          if (user?.isAnonymous ?? false) ...[
            const SizedBox(height: AppSpacing.sp8),
            Text(
              'Tài khoản khách vẫn có thể sao lưu, nhưng nên liên kết Google/email trước khi đổi máy.',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ] else if (!canSync) ...[
            const SizedBox(height: AppSpacing.sp8),
            const Text(
              'Đăng nhập để sao lưu tiến độ lên cloud.',
              style: AppTypography.caption,
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AsyncValue<ProgressSyncSummary> state) {
    if (state.isLoading) return 'Đang kiểm tra bản sao lưu...';
    final error = state.error;
    if (error != null) return 'Không kiểm tra được: $error';
    final summary = state.value;
    if (summary == null || !summary.hasCloudBackup) {
      return 'Chưa có bản sao lưu cloud.';
    }
    final updatedAt = summary.cloudUpdatedAt;
    final dateLabel = updatedAt == null
        ? 'không rõ thời gian'
        : _formatDateTime(updatedAt);
    return 'Cloud: ${summary.totalSyncedItems} mục, cập nhật $dateLabel.';
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    await _runSyncAction(
      context,
      () => ref.read(progressSyncControllerProvider.notifier).backupNow(),
    );
  }

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Khôi phục tiến độ?'),
          content: const Text(
            'Tiến độ local sẽ được cập nhật theo bản sao lưu cloud. Nội dung bài học hiện có vẫn được giữ nguyên.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Khôi phục'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) return;

    await _runSyncAction(
      context,
      () =>
          ref.read(progressSyncControllerProvider.notifier).restoreFromCloud(),
    );
  }

  Future<void> _runSyncAction(
    BuildContext context,
    Future<ProgressSyncResult> Function() action,
  ) async {
    try {
      final result = await action();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đồng bộ thất bại: $error')));
    }
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year} $hour:$minute';
  }
}
