import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'package:dedo/app.dart';
import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/db/db_helper.dart';
import 'package:dedo/repositories/category_repository.dart';
import 'package:dedo/repositories/task_repository.dart';
import 'package:dedo/screens/username/username.dart';
import 'package:dedo/services/notification_helper.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:dedo/services/permission_handler.dart';

void main() async {
  // Ensure Flutter bindings are initialized before using any plugins or async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize persistent storage for simple key-value data
  await GetStorage.init();
  final box = GetStorage();

  // Check if a username is already stored to decide the initial screen
  final hasUsername = box.hasData('username');

  // Initialize database helper singleton instance
  final dbHelper = DBHelper.instance;

  // Create repository instances that interact with database
  final categoryRepo = CategoryRepository(dbHelper);
  final taskRepo = TaskRepository(dbHelper);

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

  // Request user permissions for notifications
  await AppPermissions.requestNotificationPermissions();

  // Create helper to manage task notifications using the notification service
  final taskNotificationHelper = TaskNotificationHelper(notificationService);

  // Run the Flutter app with multiple Bloc providers for global state management
  runApp(
    MultiBlocProvider(
      providers: [
        // ThemeBloc to handle theme switching state
        BlocProvider(create: (context) => ThemeBloc()),

        // TaskBloc to manage task-related state and send notifications
        BlocProvider(
          create: (context) => TaskBloc(taskRepo, taskNotificationHelper),
        ),

        // CategoryBloc to manage category-related state
        BlocProvider(create: (context) => CategoryBloc(categoryRepo)),
      ],

      // Use MaterialApp with initial screen depending on whether username exists
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: hasUsername ? const MyApp() : const UsernameScreen(),
      ),
    ),
  );
}
