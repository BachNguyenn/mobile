import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/core/services/app_logger.dart';
import 'core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';
import 'firebase_options.dart';
import 'presentation/screens/main_navigation.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'core/services/notification_service.dart';

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
          error: (e, s) => const Scaffold(
            backgroundColor: Color(0xFFFAF8F5),
            body: Center(child: Text('Không thể xác thực. Vui lòng thử lại.')),
          ),
        );
      },
      loading: () => const _SplashScreen(),
      error: (e, s) => const Scaffold(
        backgroundColor: Color(0xFFFAF8F5),
        body: Center(
          child: Text('Không thể khởi tạo ứng dụng. Vui lòng thử lại.'),
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
      backgroundColor: const Color(0xFFFAF8F5), // app_colors.dart: background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zen Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3748).withValues(alpha: 0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  'assets/images/app_logo_clean.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Zen Japanese',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D312E), // ink
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A6B53)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
