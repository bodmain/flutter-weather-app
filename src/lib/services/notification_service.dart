import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // CHỈ yêu cầu quyền thông báo thông thường, KHÔNG yêu cầu quyền báo thức chính xác
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      // Chỉ xin quyền hiện thông báo (POST_NOTIFICATIONS)
      final bool? grantedNotification = await androidImplementation?.requestNotificationsPermission();
      return (grantedNotification ?? false);
    } else if (Platform.isIOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'weather_alerts_channel',
      'Weather Alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }

  Future<void> scheduleDailyGreeting() async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_greeting_channel',
      'Chào ngày mới',
      channelDescription: 'Thông báo chào buổi sáng lúc 7:00',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    // Sử dụng inexactAllowWhileIdle để KHÔNG cần xin quyền SCHEDULE_EXACT_ALARM
    await _notificationsPlugin.zonedSchedule(
      888,
      'Chào ngày mới! ☀️',
      'Chúc bạn một ngày làm việc hiệu quả. Đừng quên kiểm tra thời tiết hôm nay nhé!',
      _nextInstanceOfSevenAM(),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyGreeting() async {
    await _notificationsPlugin.cancel(888);
  }

  tz.TZDateTime _nextInstanceOfSevenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 7);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
