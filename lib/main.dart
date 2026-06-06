import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/app/bootstrap/startup_loading_screen.dart';
import 'package:mobile/app/composition/repository_overrides.dart';
import 'package:mobile/app/theme/app_theme_mode_mapper.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'package:mobile/features/auth/application/providers/auth_provider.dart';
import 'package:mobile/features/settings/application/providers/settings_provider.dart';
import 'package:mobile/features/settings/domain/entities/app_settings.dart';
import 'firebase_options.dart';
import 'presentation/screens/main_navigation.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'core/services/notification_service.dart';
import 'shared/widgets/app_empty_state.dart';
import 'shared/widgets/app_page_background.dart';

/// Boots Firebase before the app decides whether to show auth or main shell.
final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(overrides: appRepositoryOverrides, child: const MyApp()),
  );

  // Defer background services so the first Flutter frame is not blocked.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(_initializeDeferredServices());
  });
}

Future<void> _initializeDeferredServices() async {
  try {
    final notify = NotificationService();
    await notify.init();
    final settings = await loadPersistedSettings();
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
    final settings = ref.watch(settingsProvider).value;
    final effectiveSettings = settings ?? AppSettings.defaults;

    final brightness = effectiveSettings.themeMode.resolveBrightness(context);

    return CupertinoTheme(
      data: CupertinoThemeData(brightness: brightness),
      child: MaterialApp(
        title: 'Zen Japanese',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: effectiveSettings.themeMode.materialThemeMode,
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
      ),
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
          loading: () => const StartupLoadingScreen(
            message: 'Đang kiểm tra phiên đăng nhập...',
          ),
          error: (e, s) => const _StartupError(
            message: 'Không thể xác thực. Vui lòng thử lại.',
          ),
        );
      },
      loading: () =>
          const StartupLoadingScreen(message: 'Đang khởi tạo ứng dụng...'),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
