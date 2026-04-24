import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    
    // Explicitly using named parameter 'settings' as required by the analyzer error
    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // Explicitly using named parameters as required by the analyzer error
    await _notifications.show(
      id: 0,
      title: 'Chào buổi sáng!',
      body: 'Đến lúc học tiếng Nhật rồi.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

}
