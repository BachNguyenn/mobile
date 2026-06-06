import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/auth/domain/entities/auth_failure.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

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
      await ref
          .read(authRepositoryProvider)
          .signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      if (!mounted) return;
      _showError(_messageForRegisterError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.resolve(AppColors.zenBlue, context),
        ),
      ),
      body: AppPageBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp24,
              AppSpacing.sp12,
              AppSpacing.sp24,
              AppSpacing.sp24,
            ),
            children: [
              const _RegisterHeader(),
              const SizedBox(height: AppSpacing.sp24),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.sp20),
                borderColor: AppColors.resolve(AppColors.zenBlue, context).withValues(alpha: 0.12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Tạo tài khoản',
                        style: AppTypography.headingM.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),
                      const Text(
                        'Đăng ký để lưu tiến độ học và ôn tập SRS.',
                        style: AppTypography.caption,
                      ),
                      const SizedBox(height: AppSpacing.sp20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.bodyM.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: _inputDecoration(
                          label: 'Email',
                          hint: 'you@email.com',
                          icon: Icons.mail_outline_rounded,
                        ),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: AppSpacing.sp16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        style: AppTypography.bodyM.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: _inputDecoration(
                          label: 'Mật khẩu',
                          hint: 'Ít nhất 6 ký tự',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: _VisibilityButton(
                            isObscured: _obscurePassword,
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
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
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        style: AppTypography.bodyM.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: _inputDecoration(
                          label: 'Xác nhận mật khẩu',
                          hint: 'Nhập lại mật khẩu',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: _VisibilityButton(
                            isObscured: _obscureConfirm,
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
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
                      const SizedBox(height: AppSpacing.sp20),
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      text: 'Đã có tài khoản? ',
                      style: AppTypography.bodyM.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Đăng nhập',
                          style: AppTypography.bodyMBold.copyWith(
                            color: AppColors.resolve(AppColors.leafGreen, context),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
      prefixIcon: Icon(
        icon,
        color: AppColors.resolve(AppColors.zenBlue, context),
        size: 20,
      ),
      suffixIcon: suffixIcon,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String _messageForRegisterError(Object error) {
    if (error is! AuthFailure) return 'Đăng ký thất bại';
    switch (error.code) {
      case AuthFailureCode.emailAlreadyInUse:
        return 'Email này đã được sử dụng. Hãy thử đăng nhập.';
      case AuthFailureCode.invalidEmail:
        return 'Địa chỉ email không hợp lệ.';
      case AuthFailureCode.weakPassword:
        return 'Mật khẩu quá yếu. Hãy dùng ít nhất 6 ký tự.';
      case AuthFailureCode.operationNotAllowed:
        return 'Đăng ký email chưa được bật trong Firebase Console.';
      case AuthFailureCode.networkRequestFailed:
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      default:
        return 'Đăng ký thất bại';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.resolve(AppColors.navySoft, context)),
            boxShadow: AppColors.softShadow(context),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_logo_clean.png',
            cacheWidth: 192,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.sp16),
        Text(
          'Zen Japanese',
          style: AppTypography.headingL.copyWith(
            color: AppColors.resolve(AppColors.zenBlue, context),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          '登録して学び始めよう',
          style: AppTypography.japaneseQuote.copyWith(
            color: AppColors.resolve(AppColors.leafDark, context),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onPressed;

  const _VisibilityButton({required this.isObscured, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      tooltip: isObscured ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
      onPressed: onPressed,
      icon: Icon(
        isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        color: theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}
