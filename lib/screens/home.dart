import 'package:dedo/utils/constants/text.dart';
import 'package:dedo/widgets/appbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DAppBar(title: Text(DTexts.appName)),
      body: Center(child: Text("Home Page")),
    );
  }
}
