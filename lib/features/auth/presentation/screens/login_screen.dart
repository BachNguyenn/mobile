import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';

/// Redesigned Login Screen — Japandi Minimalism
///
/// Thiết kế tối giản với:
/// - Zen illustration (CustomPainter)
/// - Logo + tên app
/// - Email/Password sign-in
/// - Google Sign-In button
/// - Đăng ký link
/// - Câu chào tiếng Nhật
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
      await ref.read(authRepositoryProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      if (!mounted) return;

      String message = 'Đăng nhập thất bại';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            message = 'Không tìm thấy tài khoản với email này.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            message = 'Email hoặc mật khẩu không đúng.';
            break;
          case 'invalid-email':
            message = 'Địa chỉ email không hợp lệ.';
            break;
          case 'user-disabled':
            message = 'Tài khoản này đã bị vô hiệu hóa.';
            break;
          case 'too-many-requests':
            message = 'Quá nhiều lần thử. Vui lòng thử lại sau.';
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: AppSpacing.paddingH24,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sp48),

                    // ── App Logo ─────────────────────────────────
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink.withValues(alpha: 0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp32),

                    // ── App Name ─────────────────────────────────
                    Text(
                      'Zen Japanese',
                      style: AppTypography.displayLarge.copyWith(
                        letterSpacing: 1.2,
                        color: AppColors.zenBlue,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),

                    // ── Japanese subtitle ────────────────────────
                    Text(
                      '日本語を学ぼう',
                      style: AppTypography.japaneseQuote.copyWith(
                        fontSize: 18,
                        color: AppColors.mossGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp48),

                    // ── Email Field ──────────────────────────────
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyM.copyWith(color: AppColors.ink),
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

                    // ── Password Field ───────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleEmailSignIn(),
                      style: AppTypography.bodyM.copyWith(color: AppColors.ink),
                      decoration: _inputDecoration(
                        label: 'Mật khẩu',
                        hint: 'Nhập mật khẩu',
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
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.sp24),

                    // ── Email Sign-In Button ─────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleEmailSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.zenBlue,
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
                            : const Text('Đăng nhập'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp16),

                    // ── Register Link ────────────────────────────
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Chưa có tài khoản? ',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.slateGrey,
                          ),
                          children: [
                            TextSpan(
                              text: 'Đăng ký',
                              style: AppTypography.bodyMBold.copyWith(
                                color: AppColors.mossGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp24),

                    // ── Divider ──────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: AppColors.slateLight.withValues(alpha: 0.6),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sp16,
                          ),
                          child: Text(
                            'hoặc',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.slateMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: AppColors.slateLight.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sp24),

                    // ── Google Sign-In Button ────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                try {
                                  await ref
                                      .read(authRepositoryProvider)
                                      .signInWithGoogle();
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đăng nhập Google thất bại: $e',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.terracotta,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
                            border: Border.all(color: AppColors.slateLight.withValues(alpha: 0.5)),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        label: const Text('Đăng nhập với Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.slateGrey,
                          side: BorderSide(
                            color: AppColors.slateLight.withValues(alpha: 0.8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sp16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusM),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp12),

                    // ── Continue as Guest ────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() => _isLoading = true);
                                try {
                                  await ref
                                      .read(authRepositoryProvider)
                                      .signInAnonymously();
                                } catch (e) {
                                  if (!context.mounted) return;

                                  String message = 'Đăng nhập khách thất bại';
                                  if (e is FirebaseAuthException) {
                                    if (e.code == 'operation-not-allowed') {
                                      message =
                                          'Tính năng đăng nhập khách chưa được bật.';
                                    } else if (e.code ==
                                        'network-request-failed') {
                                      message =
                                          'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
                                    } else {
                                      message =
                                          'Lỗi: ${e.message ?? e.code}';
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
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.slateMuted,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sp12,
                          ),
                        ),
                        child: Text(
                          'Tiếp tục không đăng nhập',
                          style: AppTypography.bodyM.copyWith(
                            color: AppColors.slateMuted,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.slateMuted,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp16),

                    // ── Footer ───────────────────────────────────
                    Text(
                      '一歩一歩、前に進もう',
                      style: AppTypography.caption.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.slateGrey,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Text(
                      'Từng bước, tiến về phía trước',
                      style: AppTypography.labelS.copyWith(
                        color: AppColors.slateGrey,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp32),
                  ],
                ),
              ),
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
      prefixIcon: Icon(icon, color: AppColors.zenBlue, size: 20),
      suffixIcon: suffixIcon,
      labelStyle: AppTypography.bodyM.copyWith(color: AppColors.slateMuted),
      hintStyle: AppTypography.bodyM.copyWith(color: AppColors.slateLight),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sp16,
        vertical: AppSpacing.sp16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        borderSide: BorderSide(
          color: AppColors.slateLight.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        borderSide: BorderSide(
          color: AppColors.slateLight.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        borderSide: const BorderSide(color: AppColors.zenBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusM),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

