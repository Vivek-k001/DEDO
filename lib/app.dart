import 'package:dedo/bloc/theme/theme_bloc.dart';
import 'package:dedo/screens/main_page.dart';
import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using BlocBuilder to rebuild the MaterialApp whenever the ThemeMode changes
    return BlocBuilder<ThemeBloc, ThemeMode>(
      builder: (context, state) {
        return MaterialApp(
          // Disable debug banner in app UI
          debugShowCheckedModeBanner: false,

          // Use the current ThemeMode from the ThemeBloc's state (light, dark, or system)
          themeMode: state,

          // Define the light theme configuration from custom DAppTheme
          theme: DAppTheme.lightTheme,

          // Define the dark theme configuration from custom DAppTheme
          darkTheme: DAppTheme.darkTheme,

          // Application title shown in OS task switcher and elsewhere
          title: DTexts.appName,

          // Set the home screen of the app to MainPage widget
          home: const MainPage(),
        );
      },
    );
  }
}
