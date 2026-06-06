import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/domain/entities/auth_failure.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile/shared/widgets/app_card.dart';
import 'package:mobile/shared/widgets/app_page_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      if (!mounted) return;
      _showError(_messageForSignInError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      _showError(_messageForGoogleSignInError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInAnonymously();
    } catch (e) {
      if (!mounted) return;
      _showError(_messageForGuestError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: AppPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sp24,
              AppSpacing.sp32,
              AppSpacing.sp24,
              AppSpacing.sp24,
            ),
            children: [
              const _AuthHeader(
                title: 'Zen Japanese',
                subtitle: '日本語を学ぼう',
                description: 'Học từ vựng, ngữ pháp và ôn SRS mỗi ngày.',
              ),
              const SizedBox(height: AppSpacing.sp32),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.sp20),
                borderColor: AppColors.resolve(
                  AppColors.zenBlue,
                  context,
                ).withValues(alpha: 0.12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Đăng nhập',
                        style: AppTypography.headingM.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sp4),
                      const Text(
                        'Tiếp tục lộ trình học tiếng Nhật của bạn.',
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
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleEmailSignIn(),
                        style: AppTypography.bodyM.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        decoration: _inputDecoration(
                          label: 'Mật khẩu',
                          hint: 'Nhập mật khẩu',
                          icon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Hiện mật khẩu'
                                : 'Ẩn mật khẩu',
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Vui lòng nhập mật khẩu'
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.sp20),
                      _PrimaryAuthButton(
                        label: 'Đăng nhập',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleEmailSignIn,
                      ),
                      const SizedBox(height: AppSpacing.sp16),
                      const _DividerLabel(label: 'hoặc'),
                      const SizedBox(height: AppSpacing.sp16),
                      _GoogleButton(
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _handleGoogleSignIn,
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _handleGuestSignIn,
                        child: Text(
                          'Tiếp tục với tài khoản khách',
                          style: AppTypography.bodyM.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp20),
              _AuthSwitchLink(
                text: 'Chưa có tài khoản?',
                action: 'Đăng ký',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
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

  String _messageForSignInError(Object error) {
    if (error is! AuthFailure) return 'Đăng nhập thất bại';
    switch (error.code) {
      case AuthFailureCode.userNotFound:
        return 'Không tìm thấy tài khoản với email này.';
      case AuthFailureCode.wrongPassword:
      case AuthFailureCode.invalidCredential:
        return 'Email hoặc mật khẩu không đúng.';
      case AuthFailureCode.invalidEmail:
        return 'Địa chỉ email không hợp lệ.';
      case AuthFailureCode.userDisabled:
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case AuthFailureCode.tooManyRequests:
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case AuthFailureCode.networkRequestFailed:
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
      default:
        return 'Đăng nhập thất bại';
    }
  }

  String _messageForGoogleSignInError(Object error) {
    if (error is! AuthFailure) return 'Đăng nhập Google thất bại';
    return switch (error.code) {
      AuthFailureCode.canceled => 'Đăng nhập Google đã bị hủy.',
      AuthFailureCode.networkRequestFailed =>
        'Lỗi kết nối mạng. Vui lòng kiểm tra internet.',
      _ => 'Đăng nhập Google thất bại',
    };
  }

  String _messageForGuestError(Object error) {
    if (error is! AuthFailure) return 'Đăng nhập khách thất bại';
    if (error.code == AuthFailureCode.operationNotAllowed) {
      return 'Tính năng đăng nhập khách chưa được bật.';
    }
    if (error.code == AuthFailureCode.networkRequestFailed) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
    }
    return 'Đăng nhập khách thất bại';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;

  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.resolve(AppColors.navySoft, context),
            ),
            boxShadow: AppColors.softShadow(context),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_logo_clean.png',
            cacheWidth: 192,
            filterQuality: FilterQuality.medium,
          ),
        ),
        const SizedBox(height: AppSpacing.sp20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.resolve(AppColors.zenBlue, context),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.sp4),
        Text(
          subtitle,
          style: AppTypography.japaneseQuote.copyWith(
            color: AppColors.resolve(AppColors.leafDark, context),
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: AppSpacing.sp8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: AppTypography.bodyM.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _PrimaryAuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GoogleButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          'assets/images/google_logo.svg',
          width: 20,
          height: 20,
        ),
        label: const Text('Đăng nhập với Google'),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  final String label;

  const _DividerLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.resolve(AppColors.slateLight, context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sp12),
          child: Text(label, style: AppTypography.caption),
        ),
        Expanded(
          child: Divider(
            color: AppColors.resolve(AppColors.slateLight, context),
          ),
        ),
      ],
    );
  }
}

class _AuthSwitchLink extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;

  const _AuthSwitchLink({
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text.rich(
          TextSpan(
            text: '$text ',
            style: AppTypography.bodyM.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: action,
                style: AppTypography.bodyMBold.copyWith(
                  color: AppColors.resolve(AppColors.leafGreen, context),
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
