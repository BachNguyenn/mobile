import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/main_navigation.dart';
import 'presentation/screens/login_screen.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize AI config
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found
  }
  
  // Initialize Notifications
  final notify = NotificationService();
  await notify.init();
  await notify.scheduleDailyReminder(hour: 20, minute: 0);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zen Japanese',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user != null ? const MainNavigation() : const LoginScreen(),
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFFAF8F5),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        backgroundColor: const Color(0xFFFAF8F5),
        body: Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}