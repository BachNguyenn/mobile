import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/learning/domain/entities/learning_category.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Cài đặt', style: AppTypography.headingM),
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.sp16),
            children: [
              _SettingsSection(
                title: 'Hồ sơ',
                children: [
                  _ProfileTile(
                    name: user?.displayName ?? 'Zen Learner',
                    email: user?.email ?? '',
                    photoUrl: user?.photoURL,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp16),
              _SettingsSection(
                title: 'Giao diện',
                children: [
                  _ThemeModeTile(
                    selected: settings.themeMode,
                    onChanged: (mode) {
                      ref.read(settingsProvider.notifier).updateThemeMode(mode);
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
                ],
              ),
              const SizedBox(height: AppSpacing.sp16),
              _SettingsSection(
                title: 'Nhắc học',
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
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
                    activeThumbColor: AppColors.mossGreen,
                    onChanged: (enabled) async {
                      await ref
                          .read(settingsProvider.notifier)
                          .updateDailyReminderEnabled(enabled);
                      if (!enabled) {
                        await NotificationService().cancelDailyReminder();
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    enabled: settings.dailyReminderEnabled,
                    leading: const Icon(
                      Icons.schedule_rounded,
                      color: AppColors.mossGreen,
                    ),
                    title: Text('Giờ nhắc học', style: AppTypography.bodyMBold),
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
                    title: Text(
                      'Rung nhẹ khi thao tác',
                      style: AppTypography.bodyMBold,
                    ),
                    subtitle: Text(
                      'Áp dụng cho thanh điều hướng',
                      style: AppTypography.caption,
                    ),
                    value: settings.hapticsEnabled,
                    activeThumbColor: AppColors.mossGreen,
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
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.mossGreen),
        ),
        error: (error, _) =>
            Center(child: Text('Lỗi: $error', style: AppTypography.bodyM)),
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
      await NotificationService().scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
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
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sp4,
            bottom: AppSpacing.sp8,
          ),
          child: Text(title, style: AppTypography.headingS),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sp16,
            vertical: AppSpacing.sp8,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.slateLight.withValues(alpha: 0.25),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileTile({required this.name, required this.email, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.mossGreen.withValues(alpha: 0.12),
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '禅',
                  style: AppTypography.headingS.copyWith(
                    color: AppColors.mossGreen,
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
                style: AppTypography.bodyMBold.copyWith(color: AppColors.ink),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeTile({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _SegmentedSetting<ThemeMode>(
      title: 'Chế độ giao diện',
      subtitle: _themeLabel(selected),
      icon: Icons.contrast_rounded,
      selected: selected,
      values: ThemeMode.values,
      labelFor: _themeLabel,
      onChanged: onChanged,
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Hệ thống';
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
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
      values: const [0.9, 1.0, 1.15],
      labelFor: _labelFor,
      onChanged: onChanged,
    );
  }

  String _labelFor(double scale) {
    if (scale < 1.0) return 'Nhỏ';
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.mossGreen),
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
                selectedColor: AppColors.mossGreen.withValues(alpha: 0.18),
                backgroundColor: Theme.of(context).cardColor,
                showCheckmark: false,
                labelStyle: AppTypography.label.copyWith(
                  color: isSelected ? AppColors.mossGreen : AppColors.slateGrey,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXL),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.mossGreen
                        : AppColors.slateLight.withValues(alpha: 0.35),
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
      leading: const Icon(
        Icons.auto_stories_rounded,
        color: AppColors.mossGreen,
      ),
      title: Text('Lộ trình mặc định', style: AppTypography.bodyMBold),
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
        return Container(
          margin: const EdgeInsets.all(AppSpacing.sp16),
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LearningCategory.values.map((category) {
              final isSelected = category == selected;
              return ListTile(
                leading: Icon(
                  _iconFor(category),
                  color: isSelected
                      ? AppColors.mossGreen
                      : AppColors.slateMuted,
                ),
                title: Text(
                  _labelFor(category),
                  style: AppTypography.bodyMBold,
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.mossGreen,
                      )
                    : null,
                onTap: () {
                  onChanged(category);
                  Navigator.pop(context);
                },
              );
            }).toList(),
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
