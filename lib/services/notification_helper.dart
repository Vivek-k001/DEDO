import 'package:dedo/models/task_model.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();

  factory NotificationHelper() => _instance;

  NotificationHelper._internal();

  final NotificationService _notificationService = NotificationService();

  // Initialize the notification helper
  Future<void> init() async {
    await _notificationService.initNotification();
    await _notificationService.requestNotificationPermission();
  }

  // Schedule notifications for a task
  Future<void> scheduleTaskNotifications(TaskModel task) async {
    try {
      await _notificationService.scheduleTaskReminder(task);
      debugPrint('Scheduled notifications for task: ${task.title}');
    } catch (e) {
      debugPrint('Error scheduling task notifications: $e');
    }
  }

  // Cancel notifications for a task
  Future<void> cancelTaskNotifications(TaskModel task) async {
    try {
      await _notificationService.cancelTaskNotifications(task);
      debugPrint('Cancelled notifications for task: ${task.title}');
    } catch (e) {
      debugPrint('Error cancelling task notifications: $e');
    }
  }

  // Update notifications for a task (cancel and reschedule)
  Future<void> updateTaskNotifications(TaskModel task) async {
    try {
      // Cancel existing notifications
      await cancelTaskNotifications(task);

      // Schedule new notifications
      await scheduleTaskNotifications(task);

      debugPrint('Updated notifications for task: ${task.title}');
    } catch (e) {
      debugPrint('Error updating task notifications: $e');
    }
  }

  // Handle task deletion
  Future<void> handleTaskDeletion(TaskModel task) async {
    await cancelTaskNotifications(task);
  }

  // Handle task completion toggle
  Future<void> handleTaskCompletionToggle(
    TaskModel task,
    bool isCompleted,
  ) async {
    if (isCompleted) {
      // If task is marked as completed, cancel notifications
      await cancelTaskNotifications(task);
    } else {
      // If task is marked as incomplete, reschedule notifications
      await updateTaskNotifications(task);
    }
  }
}
