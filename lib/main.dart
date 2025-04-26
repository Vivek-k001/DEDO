import 'package:dedo/bloc/theme_bloc.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/screens/home.dart';
import 'package:dedo/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  runApp(BlocProvider(create: (context) => ThemeBloc(), child: const MyApp()));
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
          home: const HomePage(),
        );
      },
    );
  }
}
