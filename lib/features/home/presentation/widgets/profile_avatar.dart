import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';

class ProfileAvatar extends ConsumerWidget {
  final User? user;

  const ProfileAvatar({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: 'Tài khoản',
      child: InkWell(
        onTap: () => _showProfileMenu(context, ref),
        customBorder: const CircleBorder(),
        child: _UserAvatar(user: user, size: 36),
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final name = _displayName(user);
    final email = user?.email ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.sp16),
            padding: const EdgeInsets.all(AppSpacing.sp20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.zenBlue.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
                  decoration: BoxDecoration(
                    color: AppColors.slateLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    _UserAvatar(user: user, size: 58),
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
                              color: AppColors.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email.isEmpty ? 'Tài khoản khách' : email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sp20),
                _SheetButton(
                  icon: Icons.bar_chart_rounded,
                  label: 'Hồ sơ học tập',
                  color: AppColors.zenBlue,
                  filled: true,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(AppRoutes.analytics());
                  },
                ),
                const SizedBox(height: AppSpacing.sp8),
                _SheetButton(
                  icon: Icons.settings_rounded,
                  label: 'Cài đặt',
                  color: AppColors.leafGreen,
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(AppRoutes.settings());
                  },
                ),
                const SizedBox(height: AppSpacing.sp8),
                _SheetButton(
                  icon: Icons.logout_rounded,
                  label: 'Đăng xuất',
                  color: AppColors.error,
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await Future<void>.delayed(
                      const Duration(milliseconds: 250),
                    );
                    await ref.read(authRepositoryProvider).signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _displayName(User? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Zen Learner';
  }
}

class _UserAvatar extends StatelessWidget {
  final User? user;
  final double size;

  const _UserAvatar({required this.user, required this.size});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoURL;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.navySoft,
        border: Border.all(
          color: AppColors.zenBlue.withValues(alpha: 0.12),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _AvatarFallback(user: user),
            )
          : _AvatarFallback(user: user),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final User? user;

  const _AvatarFallback({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();
    final initial = displayName?.isNotEmpty == true
        ? displayName![0].toUpperCase()
        : email?.isNotEmpty == true
        ? email![0].toUpperCase()
        : '禅';

    return Center(
      child: Text(
        initial,
        style: AppTypography.bodyMBold.copyWith(
          color: AppColors.zenBlue,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final bool filled;

  const _SheetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppColors.white : color;
    final background = filled ? color : AppColors.white;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: BorderSide(color: color.withValues(alpha: filled ? 0.0 : 0.28)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
          ),
        ),
      ),
    );
  }
}
