import 'package:dedo/models/task_model.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskNotificationHelper {
  final NotificationService _notificationService;

  // Constructor receives a NotificationService instance
  TaskNotificationHelper(this._notificationService);

  // Schedule all relevant notifications for a given task
  Future<void> scheduleTaskNotifications(TaskModel task) async {
    try {
      // Parse the task date (e.g., "25/12/2024") into a DateTime object
      final taskDate = DateFormat('dd/MM/yyyy').parse(task.date);

      // Parse the start and end times into DateTime objects combined with taskDate
      final startTime = _parseTime(task.startTime, taskDate);
      final endTime = _parseTime(task.endTime, taskDate);

      // Schedule reminder notification if remind time is greater than 0
      if (task.remind > 0) {
        // Calculate reminder time by subtracting the reminder minutes from startTime
        final reminderTime = startTime.subtract(Duration(minutes: task.remind));
        debugPrint('Scheduling reminder at $reminderTime');

        // Only schedule if reminder time is in the future
        if (reminderTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleNotification(
            id: _generateId(task.id!, 'reminder'), // Unique ID for reminder
            title: '🔔 Reminder: ${task.title}',
            body: 'Starts in ${task.remind} minutes',
            scheduledTime: reminderTime,
          );
        }
      }

      debugPrint('Scheduling start notification at $startTime');
      // Schedule notification at task start time if it is in the future
      if (startTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: _generateId(task.id!, 'start'), // Unique ID for start
          title: '⏰ ${task.title}',
          body: 'Task is starting now',
          scheduledTime: startTime,
        );
      }

      debugPrint('Scheduling end notification at $endTime');
      // Schedule notification at task end time if it is after start and now
      if (endTime.isAfter(startTime) && endTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: _generateId(task.id!, 'end'), // Unique ID for end
          title: '✅ ${task.title}',
          body: 'Task is ending now',
          scheduledTime: endTime,
        );
      }
    } catch (e) {
      // Catch and debugPrint any errors during scheduling
      debugPrint('Error scheduling notifications: $e');
    }

    // Additional debug debugPrints showing parsed times and task info
    debugPrint('Scheduling notifications for task: ${task.title}');
    debugPrint(
      'Task date: ${task.date}, startTime: ${task.startTime}, endTime: ${task.endTime}',
    );
    final taskDate = DateFormat('dd/MM/yyyy').parse(task.date);
    final startTime = _parseTime(task.startTime, taskDate);
    debugPrint('Parsed startTime: $startTime');
    final endTime = _parseTime(task.endTime, taskDate);
    debugPrint('Parsed endTime: $endTime');
  }

  // Cancel all notifications related to a task (reminder, start, end)
  Future<void> cancelTaskNotifications(TaskModel task) async {
    try {
      await _notificationService.cancelNotification(
        _generateId(task.id!, 'reminder'),
      );
      await _notificationService.cancelNotification(
        _generateId(task.id!, 'start'),
      );
      await _notificationService.cancelNotification(
        _generateId(task.id!, 'end'),
      );
    } catch (e) {
      debugPrint('Error cancelling notifications: $e');
    }
  }

  // Helper method to parse time string (e.g., "10:30 AM") into DateTime combined with given date
  DateTime _parseTime(String timeString, DateTime date) {
    final format = DateFormat('hh:mm a'); // Format for parsing time
    final time = format.parse(timeString);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Generate unique notification ID based on task ID and notification type
  int _generateId(int taskId, String type) {
    // Map each notification type to a unique code
    const typeCodes = {'reminder': 1, 'start': 2, 'end': 3};
    return taskId * 10 + typeCodes[type]!;
  }
}
