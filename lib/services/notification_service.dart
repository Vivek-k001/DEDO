import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    // Prevent re-initialization
    if (_isInitialized) return;

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

    await notificationPlugin.initialize(initSettings);
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
    return notificationPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(),
    );
  }
}
