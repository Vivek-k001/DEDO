import 'package:dedo/bloc/category/category_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/db/db_helper.dart';
import 'package:dedo/repositories/category_repository.dart';
import 'package:dedo/repositories/task_repository.dart';
import 'package:dedo/screens/main_page.dart';
import 'package:dedo/services/notification_helper.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  final dbHelper = DBHelper.instance;

  final categoryRepo = CategoryRepository(dbHelper);

  final taskRepo = TaskRepository(dbHelper);

  final notificationHelper = NotificationHelper();
  await notificationHelper.init();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(
          create: (context) => TaskBloc(taskRepo, notificationHelper),
        ),
        BlocProvider(create: (context) => CategoryBloc(categoryRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: state,
          theme: DAppTheme.lightTheme,
          darkTheme: DAppTheme.darkTheme,
          title: DTexts.appName,
          home: const MainPage(),
        );
      },
    );
  }
}
