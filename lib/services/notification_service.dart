import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/task.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static NotificationDetails _details(String channelId, String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        color: const Color(0xFF007AFF), // Apple System Blue accent
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Schedule all 3 notifications for a task
  static Future<void> scheduleTaskNotifications(Task task) async {
    await cancelTaskNotifications(task.id);

    final now = DateTime.now();

    // 1. Reminder notification
    final reminderTime =
        task.startTime.subtract(Duration(minutes: task.reminderMinutes));
    if (reminderTime.isAfter(now)) {
      await _scheduleNotification(
        id: _notifId(task.id, 'r'),
        title: '⏰ Reminder: ${task.title}',
        body: 'Starting in ${task.reminderMinutes} minutes',
        scheduledDate: reminderTime,
        channelId: 'dedo_reminder',
        channelName: 'Dedo Reminders',
      );
    }

    // 2. Start time notification
    if (task.startTime.isAfter(now)) {
      await _scheduleNotification(
        id: _notifId(task.id, 's'),
        title: '🚀 Starting Now: ${task.title}',
        body: task.note ?? 'Your task has started!',
        scheduledDate: task.startTime,
        channelId: 'dedo_start',
        channelName: 'Dedo Start',
      );
    }

    // 3. End time notification
    if (task.endTime.isAfter(now)) {
      await _scheduleNotification(
        id: _notifId(task.id, 'e'),
        title: '✅ Time Up: ${task.title}',
        body: 'Your task time has ended.',
        scheduledDate: task.endTime,
        channelId: 'dedo_end',
        channelName: 'Dedo End',
      );
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String channelId,
    required String channelName,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        _details(channelId, channelName),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Ignore silently – notification may not be schedulable
    }
  }

  static Future<void> cancelTaskNotifications(String taskId) async {
    try {
      await _plugin.cancel(_notifId(taskId, 'r'));
      await _plugin.cancel(_notifId(taskId, 's'));
      await _plugin.cancel(_notifId(taskId, 'e'));
    } catch (_) {
      // Ignore silently if notification plugin cannot cancel
    }
  }

  static int _notifId(String taskId, String suffix) {
    const map = {'r': 0, 's': 1, 'e': 2};
    final hash = taskId.hashCode.abs() % 100000;
    return hash * 10 + (map[suffix] ?? 0);
  }
}
