import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_typography.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'presentation/screens/main_navigation.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'core/services/notification_service.dart';
import 'shared/widgets/app_empty_state.dart';
import 'shared/widgets/app_loading_indicator.dart';
import 'shared/widgets/app_page_background.dart';

final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeDeferredServices());
  });
}

Future<void> _initializeDeferredServices() async {
  try {
    final notify = NotificationService();
    await notify.init();
    final settings = await AppSettingsStore.load();
    if (settings.dailyReminderEnabled) {
      await notify.scheduleDailyReminder(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      );
    } else {
      await notify.cancelDailyReminder();
    }
  } catch (error, stackTrace) {
    AppLogger.warning(
      'Deferred service initialization failed',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final effectiveSettings = settings ?? AppSettings.defaults;

    return MaterialApp(
      title: 'Zen Japanese',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: effectiveSettings.themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(effectiveSettings.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseInit = ref.watch(firebaseInitProvider);

    return firebaseInit.when(
      data: (_) {
        final authState = ref.watch(authStateProvider);
        return authState.when(
          data: (user) =>
              user != null ? const MainNavigation() : const LoginScreen(),
          loading: () => const _SplashScreen(),
          error: (e, s) => const _StartupError(
            message: 'Không thể xác thực. Vui lòng thử lại.',
          ),
        );
      },
      loading: () => const _SplashScreen(),
      error: (e, s) => const _StartupError(
        message: 'Không thể khởi tạo ứng dụng. Vui lòng thử lại.',
      ),
    );
  }
}

class _StartupError extends StatelessWidget {
  final String message;

  const _StartupError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppPageBackground(
        child: AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: 'Có lỗi xảy ra',
          message: message,
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppPageBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyDark.withValues(alpha: 0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusL),
                  child: Image.asset(
                    'assets/images/app_logo_clean.png',
                    fit: BoxFit.contain,
                    cacheWidth: 240,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sp24),
              Text(
                'Zen Japanese',
                style: AppTypography.headingM.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sp32),
              const SizedBox(
                width: 28,
                height: 28,
                child: AppLoadingIndicator(color: AppColors.leafGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
