import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Widget "trạng thái rỗng" chuẩn hóa cho toàn ứng dụng.
///
/// Hiển thị icon + message khi danh sách trống hoặc không có kết quả tìm kiếm.
///
/// ```dart
/// const AppEmptyState(
///   icon: Icons.search_off_rounded,
///   message: 'Không tìm thấy từ vựng nào.',
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? title;

  const AppEmptyState({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.message,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);
    final subtleColor = theme.colorScheme.onSurface.withValues(alpha: 0.25);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: subtleColor),
            const SizedBox(height: AppSpacing.sp12),
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.headingS.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sp8),
            ],
            Text(
              message,
              style: AppTypography.bodyM.copyWith(color: mutedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Trả về widget bọc trong `SliverFillRemaining` cho CustomScrollView.
  static Widget sliver({
    IconData icon = Icons.search_off_rounded,
    required String message,
    String? title,
  }) {
    return SliverFillRemaining(
      child: AppEmptyState(icon: icon, message: message, title: title),
    );
  }
}
