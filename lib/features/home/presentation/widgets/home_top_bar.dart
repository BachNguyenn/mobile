import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/domain/entities/auth_user.dart';
import 'package:mobile/features/home/presentation/widgets/profile_avatar.dart';
import 'package:mobile/presentation/navigation/app_routes.dart';

class HomeTopBar extends StatelessWidget {
  final AuthUser? user;

  const HomeTopBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = _displayName(user);

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusM),
            border: Border.all(
              color: AppColors.resolve(AppColors.navySoft, context),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_logo_clean.png',
            cacheWidth: 96,
            filterQuality: FilterQuality.medium,
          ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '日本語を少しずつ',
                style: AppTypography.label.copyWith(
                  color: AppColors.resolve(AppColors.leafDark, context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sp8),
        SizedBox.square(
          dimension: 44,
          child: IconButton(
            tooltip: 'Tìm kiếm',
            onPressed: () => Navigator.push(context, AppRoutes.dictionary()),
            icon: const Icon(Icons.search_rounded),
            color: AppColors.resolve(AppColors.zenBlue, context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 44, height: 44),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: AppSpacing.sp4),
        ProfileAvatar(user: user),
        const SizedBox(width: 2),
      ],
    );
  }

  String _displayName(AuthUser? user) {
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'bạn';
  }
}
