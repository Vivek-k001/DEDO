import 'package:dedo/bloc/categories/categories_bloc.dart';
import 'package:dedo/bloc/task/task_bloc.dart';
import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/db/database_provider.dart';
import 'package:dedo/db/db_helper.dart';
import 'package:dedo/repositories/category_repository.dart';
import 'package:dedo/screens/main.dart';
import 'package:dedo/services/notification_service.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await NotificationService().requestNotificationPermission();
  await NotificationService().initNotification();

  final dbHelper = DBHelper.instance;

  final databaseProvider = DatabaseProvider(dbHelper);

  final categoryRepository = CategoryRepository(databaseProvider);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => TaskBloc()),
        BlocProvider(create: (context) => CategoryBloc(categoryRepository)),
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
