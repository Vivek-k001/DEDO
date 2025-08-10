import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  // Singleton pattern for global access
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Initialize the notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Set up timezone data
    await _setupTimeZone();

    // Android-specific initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS-specific initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
        );

    // Combined platform settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin with settings
    await _notifications.initialize(settings);

    _isInitialized = true;
  }

  // Set up timezone configuration using device's current timezone
  Future<void> _setupTimeZone() async {
    tz_data.initializeTimeZones(); // Load timezone data
    final timeZone =
        await FlutterTimezone.getLocalTimezone(); // Get current timezone
    debugPrint('Local timezone detected: $timeZone');
    tz.setLocalLocation(tz.getLocation(timeZone)); // Set local timezone
    debugPrint('Timezone set to: ${tz.local.name}');
  }

  // Define notification appearance and behavior
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel', // channel ID
        'Task Reminders', // channel name
        channelDescription: 'Notifications for task reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true),
    );
  }

  // Schedule a notification for a specific DateTime
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Avoid scheduling past notifications
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Cancel a single notification using its ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Cancel all notifications at once
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
