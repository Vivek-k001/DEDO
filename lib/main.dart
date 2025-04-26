import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/screens/home.dart';
import 'package:dedo/utils/theme/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: DAppTheme.lightTheme,
      darkTheme: DAppTheme.darkTheme,
      title: DTexts.appName,
      home: const HomePage(),
    );
  }
}
