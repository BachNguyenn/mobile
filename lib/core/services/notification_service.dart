import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {},
    );

    // Android 13+ requires runtime permission before scheduled reminders work.
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Show an immediate test notification (useful for debugging).
  Future<void> showTestNotification() async {
    await init();

    await _notifications.show(
      id: 99,
      title: 'Thông báo thử',
      body: 'Notification service đang hoạt động!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await init();

    // Keep a single reminder slot so settings changes do not duplicate alarms.
    await cancelDailyReminder();

    await _notifications.zonedSchedule(
      id: 0,
      title: 'Đến giờ học rồi',
      body: 'Dành vài phút ôn tiếng Nhật hôm nay nhé.',
      scheduledDate: _nextInstanceOfTime(hour, minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Nhắc nhở hằng ngày',
          channelDescription: 'Nhắc bạn học tiếng Nhật mỗi ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    await init();
    await _notifications.cancel(id: 0);
  }

  /// Returns the next occurrence of [hour]:[minute] in local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
