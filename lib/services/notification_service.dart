import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    // Prevent re-initialization
    if (_isInitialized) return;
    _isInitialized = true;

    const initAndroidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initIOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initAndroidSettings,
      iOS: initIOSSettings,
    );

    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          print('Notification payload: ${response.payload}');
        }
      },
    );
  }

  // Notification Details Setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  // Show Notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationPlugin.show(id, title, body, notificationDetails());
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      debugPrint('Notification permission already granted');
      return true;
    }

    final result = await Permission.notification.request();

    if (result.isGranted) {
      debugPrint('Notification permission granted');
      return true;
    } else if (result.isDenied) {
      debugPrint('Notification permission denied');
      return false;
    } else if (result.isPermanentlyDenied) {
      debugPrint('Notification permission permanently denied');
      return false;
    }

    return false;
  }
}
