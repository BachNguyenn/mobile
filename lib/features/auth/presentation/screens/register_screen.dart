import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Màn hình Đăng ký — Japandi Minimalism
///
/// Cho phép đăng ký bằng email/mật khẩu.
/// Sau khi đăng ký thành công, Firebase Auth tự động đăng nhập
/// và AuthWrapper sẽ chuyển sang MainNavigation.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // Đăng ký thành công → Firebase tự đăng nhập → AuthWrapper xử lý navigation
    } catch (e) {
      if (!mounted) return;

      String message = 'Đăng ký thất bại';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Email này đã được sử dụng. Hãy thử đăng nhập.';
            break;
          case 'invalid-email':
            message = 'Địa chỉ email không hợp lệ.';
            break;
          case 'weak-password':
            message = 'Mật khẩu quá yếu. Hãy dùng ít nhất 6 ký tự.';
            break;
          case 'operation-not-allowed':
            message =
                'Đăng ký email chưa được bật trong Firebase Console.';
            break;
          case 'network-request-failed':
            message = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
            break;
          default:
            message = 'Lỗi: ${e.message ?? e.code}';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.terracotta,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.slateGrey,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingH24,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sp16),

                // ── Header ──────────────────────────────────
                Text('Tạo tài khoản', style: AppTypography.displayLarge),
                const SizedBox(height: AppSpacing.sp8),
                Text(
                  '登録して学び始めよう',
                  style: AppTypography.japaneseQuote.copyWith(
                    fontSize: 16,
                    color: AppColors.mossGreen,
                  ),
                ),
                const SizedBox(height: AppSpacing.sp4),
                Text(
                  'Đăng ký để bắt đầu hành trình học tiếng Nhật',
                  style: AppTypography.bodyM.copyWith(
                    color: AppColors.slateMuted,
                  ),
                ),

                const SizedBox(height: AppSpacing.sp32),

                // ── Email Field ─────────────────────────────
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Email',
                    hint: 'your@email.com',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(value.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sp16),

                // ── Password Field ──────────────────────────
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Mật khẩu',
                    hint: 'Ít nhất 6 ký tự',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.slateMuted,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sp16),

                // ── Confirm Password Field ──────────────────
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  decoration: _inputDecoration(
                    label: 'Xác nhận mật khẩu',
                    hint: 'Nhập lại mật khẩu',
                    icon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.slateMuted,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Mật khẩu không khớp';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.sp32),

                // ── Register Button ─────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mossGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sp16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusS),
                      ),
                      textStyle: AppTypography.bodyMBold.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text('Đăng ký'),
                  ),
                ),

                const SizedBox(height: AppSpacing.sp20),

                // ── Back to Login ───────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: TextSpan(
                        text: 'Đã có tài khoản? ',
                        style: AppTypography.bodyM.copyWith(
                          color: AppColors.slateMuted,
                        ),
                        children: [
                          TextSpan(
                            text: 'Đăng nhập',
                            style: AppTypography.bodyMBold.copyWith(
                              color: AppColors.mossGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sp32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.mossGreen, size: 20),
      suffixIcon: suffixIcon,
      labelStyle: AppTypography.bodyM.copyWith(color: AppColors.slateGrey),
      hintStyle: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp16,
        vertical: AppSpacing.sp12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: BorderSide(
          color: AppColors.slateLight.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: BorderSide(
          color: AppColors.slateLight.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(color: AppColors.mossGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusS),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
