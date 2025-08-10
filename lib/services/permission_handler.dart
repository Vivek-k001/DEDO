import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  // Request notification permission from the user
  static Future<bool> requestNotificationPermissions() async {
    final status = await Permission.notification.request();
    return status.isGranted; // Returns true if granted
  }

  // Check current status of notification permission
  static Future<bool> checkNotificationPermissions() async {
    final status = await Permission.notification.status;
    return status.isGranted; // Returns true if already granted
  }

  // Request all relevant permissions (platform-specific)
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    return await [
      Permission.notification,
      if (defaultTargetPlatform == TargetPlatform.iOS) ...[
        Permission.calendarFullAccess, // For iOS calendar
        Permission.reminders,          // For iOS reminders
      ],
    ].request(); // Requests permissions and returns their statuses
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
