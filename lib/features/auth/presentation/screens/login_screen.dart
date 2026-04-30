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
                    const SizedBox(height: 40),

                    // ── Zen Illustration ─────────────────────────
                    SizedBox(
                      height: 140,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _LoginZenPainter(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp24),

                    // ── App Name ─────────────────────────────────
                    Text(
                      'Zen Japanese',
                      style: AppTypography.displayLarge.copyWith(
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp8),

                    // ── Japanese subtitle ────────────────────────
                    Text(
                      '日本語を学ぼう',
                      style: AppTypography.japaneseQuote.copyWith(
                        fontSize: 18,
                        color: AppColors.mossGreen,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp32),

                    // ── Email Field ──────────────────────────────
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

                    const SizedBox(height: AppSpacing.sp12),

                    // ── Password Field ───────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleEmailSignIn(),
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
                            : const Text('Đăng nhập'),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sp12),

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
                            color: AppColors.slateMuted,
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
                            color: AppColors.slateLight.withValues(alpha: 0.5),
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
                            color: AppColors.slateLight.withValues(alpha: 0.5),
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
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slateGrey,
                              ),
                            ),
                          ),
                        ),
                        label: const Text('Đăng nhập với Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.slateGrey,
                          side: BorderSide(
                            color: AppColors.slateLight.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sp12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusS),
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
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sp4),
                    Text(
                      'Từng bước, tiến về phía trước',
                      style: AppTypography.labelS,
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

/// CustomPainter cho illustration Zen trên Login screen
class _LoginZenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // ── Raked Sand Circles ─────────────────────────────────
    final sandPaint = Paint()
      ..color = AppColors.slateLight.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 1; i <= 6; i++) {
      canvas.drawCircle(
        Offset(centerX, centerY + 10),
        i * 18.0,
        sandPaint,
      );
    }

    // ── Zen Stones (3 đá) ──────────────────────────────────
    final stonePaint = Paint()
      ..color = AppColors.slateMuted.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Đá lớn giữa
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 32,
        height: 22,
      ),
      stonePaint,
    );

    // Đá nhỏ trái
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 40, centerY + 12),
        width: 20,
        height: 14,
      ),
      stonePaint,
    );

    // Đá nhỏ phải
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + 35, centerY + 8),
        width: 16,
        height: 12,
      ),
      stonePaint,
    );

    // ── Bonsai cách điệu ──────────────────────────────────
    final trunkPaint = Paint()
      ..color = AppColors.terracotta.withValues(alpha: 0.3)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Trunk
    canvas.drawLine(
      Offset(centerX - 65, centerY + 15),
      Offset(centerX - 65, centerY - 20),
      trunkPaint,
    );

    // Canopy
    final canopyPaint = Paint()
      ..color = AppColors.mossGreen.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX - 65, centerY - 28),
      18,
      canopyPaint,
    );

    // ── Sakura petals ──────────────────────────────────────
    final petalPaint = Paint()
      ..color = AppColors.sakura.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final petalPositions = [
      Offset(centerX + 60, centerY - 30),
      Offset(centerX + 75, centerY - 15),
      Offset(centerX - 80, centerY - 40),
      Offset(centerX + 50, centerY + 30),
      Offset(centerX - 30, centerY - 45),
    ];

    for (final pos in petalPositions) {
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 6, height: 4),
        petalPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
