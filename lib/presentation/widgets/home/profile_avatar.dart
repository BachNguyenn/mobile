import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class ProfileAvatar extends StatelessWidget {
  final User? user;

  const ProfileAvatar({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showProfileMenu(context);
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.mossGreen.withValues(alpha: 0.12),
          border: Border.all(
            color: AppColors.mossGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: user?.photoURL != null
              ? Image.network(
                  user!.photoURL!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, st) => _buildFallbackAvatar(),
                )
              : _buildFallbackAvatar(),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    final initial = user?.displayName?.isNotEmpty == true
        ? user!.displayName![0].toUpperCase()
        : user?.email?.isNotEmpty == true
            ? user!.email![0].toUpperCase()
            : '禅';

    return Center(
      child: Text(
        initial,
        style: AppTypography.label.copyWith(
          color: AppColors.mossGreen,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(AppSpacing.sp16),
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusL),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.sp16),
                decoration: BoxDecoration(
                  color: AppColors.slateLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // User info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.mossGreen.withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Text(
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0].toUpperCase()
                            : '禅',
                        style: AppTypography.headingS.copyWith(
                          color: AppColors.mossGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sp16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Zen Learner',
                          style: AppTypography.bodyMBold.copyWith(
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? '',
                          style: AppTypography.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sp20),
              // Sign out button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Đăng xuất'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sp12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusS),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp8),
            ],
          ),
        );
      },
    );
  }
}
