import 'package:flutter/material.dart';

/// Loading indicator chuẩn hóa cho toàn ứng dụng.
///
/// Mặc định sử dụng màu primary từ theme để đảm bảo nhất quán
/// giữa light mode và dark mode.
///
/// ```dart
/// // Dùng mặc định (primary color)
/// const AppLoadingIndicator()
///
/// // Dùng trong SliverFillRemaining
/// AppLoadingIndicator.sliver()
/// ```
class AppLoadingIndicator extends StatelessWidget {
  /// Màu tùy chỉnh. Nếu `null`, dùng `Theme.of(context).colorScheme.primary`.
  final Color? color;

  const AppLoadingIndicator({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Trả về widget bọc trong `SliverFillRemaining` cho CustomScrollView.
  static Widget sliver({Color? color}) {
    return SliverFillRemaining(
      child: AppLoadingIndicator(color: color),
    );
  }

  /// Trả về Scaffold toàn trang với loading indicator.
  static Widget scaffold({Color? color}) {
    return Scaffold(
      body: AppLoadingIndicator(color: color),
    );
  }
}
