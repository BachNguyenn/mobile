import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/settings/presentation/providers/settings_provider.dart';
import 'presentation/screens/main_navigation.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'core/services/notification_service.dart';

final firebaseInitProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp();
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
  } catch (_) {
    // Notifications should never block app startup.
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
          error: (e, s) => Scaffold(
            backgroundColor: const Color(0xFFFAF8F5),
            body: Center(child: Text('Lỗi Auth: $e')),
          ),
        );
      },
      loading: () => const _SplashScreen(),
      error: (e, s) => Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        body: Center(child: Text('Lỗi Khởi tạo: $e')),
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4A6B53), // mossGreen
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4A6B53).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 50,
                color: Colors.white,
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
