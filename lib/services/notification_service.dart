import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:dedo/models/task_model.dart';
import 'package:intl/intl.dart';

class NotificationService {
  final notificationPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initNotification() async {
    // Prevent re-initialization
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(await _getLocalTimeZone()));

    // Android initialization settings
    const AndroidInitializationSettings initAndroidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initIOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: initAndroidSettings,
      iOS: initIOSSettings,
    );

    // Initialize the plugin
    await notificationPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null) {
          debugPrint('Notification payload: ${response.payload}');
        }
      },
    );

    _isInitialized = true;
    debugPrint('Notification service initialized');
  }

  // Get local timezone (default to UTC if not available)
  Future<String> _getLocalTimeZone() async {
    try {
      // Use device timezone
      return tz.local.name;
    } catch (e) {
      debugPrint('Failed to get timezone: $e');
      return 'UTC';
    }
  }

  // Notification Details Setup
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel_id',
        'Task Notifications',
        channelDescription: 'Notifications for task reminders',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await notificationPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    debugPrint('Notification scheduled for: $scheduledTime');
  }

  // Schedule a repeating notification based on the repeat option
  Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String repeatOption,
    String? payload,
  }) async {
    debugPrint('Scheduling repeating notification with option: $repeatOption');

    if (repeatOption == "None") {
      // Just schedule a one-time notification
      await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      );
      return;
    }

    // Create a base scheduledDateTime in the local timezone
    final scheduledDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Define a function to match the repeat pattern
    tz.TZDateTime Function(tz.TZDateTime) getNextDate;

    switch (repeatOption) {
      case "Daily":
        getNextDate = (tz.TZDateTime time) => time.add(const Duration(days: 1));
        break;
      case "Weekly":
        getNextDate = (tz.TZDateTime time) => time.add(const Duration(days: 7));
        break;
      case "Monthly":
        getNextDate = (tz.TZDateTime time) {
          // Add a month to the current date
          final nextMonth = DateTime(
            time.year,
            time.month + 1,
            time.day,
            time.hour,
            time.minute,
          );
          return tz.TZDateTime.from(nextMonth, tz.local);
        };
        break;
      default:
        // Default to no repeat (shouldn't reach here)
        await scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledTime: scheduledTime,
          payload: payload,
        );
        return;
    }

    await _scheduleRepeating(
      id: id,
      title: title,
      body: body,
      scheduledDateTime: scheduledDateTime,
      getNextDate: getNextDate,
      payload: payload,
    );
  }

  // Helper function to schedule repeating notifications
  Future<void> _scheduleRepeating({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDateTime,
    required tz.TZDateTime Function(tz.TZDateTime) getNextDate,
    String? payload,
  }) async {
    // Schedule the first occurrence
    await notificationPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDateTime,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    // Schedule the next occurrence
    final nextDate = getNextDate(scheduledDateTime);

    // Schedule with a different ID to avoid conflicts
    await notificationPlugin.zonedSchedule(
      id + 1000,
      title,
      body,
      nextDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );

    debugPrint(
      'Repeating notification scheduled for: $scheduledDateTime and next at $nextDate',
    );
  }

  // Schedule task reminder based on task details
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!_isInitialized) {
      await initNotification();
    }

    // Parse the task date and start time
    final taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
    final startTimeParts = task.startTime.split(' ');
    final startTimeString = startTimeParts[0]; // e.g., "10:30"
    final startTimeAmPm = startTimeParts[1]; // e.g., "AM" or "PM"

    // Parse the time
    final timeFormat = DateFormat('hh:mm a');
    final startTime = timeFormat.parse('$startTimeString $startTimeAmPm');

    // Combine date and time
    final scheduledStartTime = DateTime(
      taskDate.year,
      taskDate.month,
      taskDate.day,
      startTime.hour,
      startTime.minute,
    );

    // Calculate reminder time (minutes before task)
    final reminderTime = scheduledStartTime.subtract(
      Duration(minutes: task.remind),
    );

    // Only schedule if the reminder time is in the future
    if (reminderTime.isAfter(DateTime.now())) {
      // Schedule reminder notification
      await scheduleNotification(
        id: task.hashCode,
        title: 'Reminder: ${task.title}',
        body: '${task.title} starts in ${task.remind} minutes',
        scheduledTime: reminderTime,
        payload: 'task_${task.hashCode}',
      );

      // Schedule start time notification if it's in the future
      if (scheduledStartTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: task.hashCode + 1,
          title: 'Task Starting: ${task.title}',
          body: '${task.title} is starting now',
          scheduledTime: scheduledStartTime,
          payload: 'task_${task.hashCode}_start',
        );
      }

      // Parse end time if available
      if (task.endTime.isNotEmpty) {
        final endTimeParts = task.endTime.split(' ');
        final endTimeString = endTimeParts[0];
        final endTimeAmPm = endTimeParts[1];

        final endTime = timeFormat.parse('$endTimeString $endTimeAmPm');

        final scheduledEndTime = DateTime(
          taskDate.year,
          taskDate.month,
          taskDate.day,
          endTime.hour,
          endTime.minute,
        );

        // Schedule end time notification if it's in the future
        if (scheduledEndTime.isAfter(DateTime.now())) {
          await scheduleNotification(
            id: task.hashCode + 2,
            title: 'Task Ending: ${task.title}',
            body: '${task.title} is ending now',
            scheduledTime: scheduledEndTime,
            payload: 'task_${task.hashCode}_end',
          );
        }
      }

      // If task has repeat option, schedule repeating notifications
      if (task.repeat != "None") {
        await scheduleRepeatingNotification(
          id: task.hashCode + 100,
          title: 'Recurring Task: ${task.title}',
          body: 'Your recurring task "${task.title}" is due today',
          scheduledTime: scheduledStartTime,
          repeatOption: task.repeat,
          payload: 'task_${task.hashCode}_recurring',
        );
      }
    }
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await notificationPlugin.cancel(id);
  }

  // Cancel all task notifications related to a specific task
  Future<void> cancelTaskNotifications(TaskModel task) async {
    // Cancel all potential IDs used for this task
    await notificationPlugin.cancel(task.hashCode); // Reminder
    await notificationPlugin.cancel(task.hashCode + 1); // Start time
    await notificationPlugin.cancel(task.hashCode + 2); // End time
    await notificationPlugin.cancel(task.hashCode + 100); // Recurring base
    await notificationPlugin.cancel(task.hashCode + 1000); // Next recurring
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationPlugin.cancelAll();
  }

  // Request notification permissions
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
      // Prompt user to open app settings
      return false;
    }
    return false;
  }
}
